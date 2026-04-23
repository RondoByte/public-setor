-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SAFRA NA MÃO — PUBLIC SECTOR SECURITY MIGRATION                    ║
-- ║  Run this in Supabase SQL Editor                                    ║
-- ╠══════════════════════════════════════════════════════════════════════╣
-- ║  Strategy: RPC with SECURITY DEFINER                                ║
-- ║  - Existing RLS policies are NOT changed                            ║
-- ║  - The RPC function bypasses RLS (runs as owner)                    ║
-- ║  - anon role NEVER gets direct table access                         ║
-- ║  - Only whitelisted fields are returned                             ║
-- ╚══════════════════════════════════════════════════════════════════════╝
--
-- YOUR EXISTING POLICIES (kept intact — no changes needed):
--
--  | policyname                        | tablename    |
--  | --------------------------------- | ------------ |
--  | Produtor só acessa seus setores   | sectors      |
--  | Users can view own pest_control   | pest_control |
--  | Users can view own sectors        | sectors      |
--  | Users can insert own sectors      | sectors      |
--  | Users can update own sectors      | sectors      |
--  | Users can delete own sectors      | sectors      |
--  | Users can insert own pest_control | pest_control |
--  | Users can update own pest_control | pest_control |
--  | Users can delete own pest_control | pest_control |
--  | Usuário acessa apenas seus lotes  | batches      |
--  | tecnico reads sectors             | sectors      |
--  | tecnico reads pest_control        | pest_control |
--  | tecnico reads batches             | batches      |
--


-- ════════════════════════════════════════════════════════════════════════
-- 1. ENABLE pgcrypto (for gen_random_bytes)
--    Usually already enabled on Supabase, but safe to run again.
-- ════════════════════════════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- ════════════════════════════════════════════════════════════════════════
-- 2. ADD public_token COLUMN TO sectors TABLE
--    - NULL means "not public" (default for all existing sectors)
--    - A 32-char hex string means "publicly accessible via this token"
--    - UNIQUE constraint prevents collisions
-- ════════════════════════════════════════════════════════════════════════

ALTER TABLE sectors
  ADD COLUMN IF NOT EXISTS public_token TEXT UNIQUE DEFAULT NULL;

-- Partial index: fast lookups only for sectors that have a token
CREATE INDEX IF NOT EXISTS idx_sectors_public_token
  ON sectors (public_token)
  WHERE public_token IS NOT NULL AND deleted_at IS NULL;


-- ════════════════════════════════════════════════════════════════════════
-- 3. HELPER: Generate a secure random token
--    128 bits of entropy → 32 hex chars → brute-force infeasible
-- ════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION generate_public_token()
RETURNS TEXT
LANGUAGE sql
VOLATILE
AS $$
  SELECT encode(gen_random_bytes(16), 'hex');
$$;


-- ════════════════════════════════════════════════════════════════════════
-- 4. MAIN RPC: get_public_sector(token)
--    Called by the public-setor Vue app.
--    SECURITY DEFINER = runs as DB owner, bypasses ALL RLS policies.
--    This means anon never needs direct SELECT on any table.
--
--    Returns JSON:
--      Success → { sector: {...}, batches: [...], pest_controls: [...] }
--      Error   → { error: 'invalid_token' | 'not_found' }
-- ════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION get_public_sector(p_token TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
DECLARE
  v_sector_id UUID;
  v_result    JSON;
BEGIN
  -- ── Step 1: Validate token format (32 lowercase hex chars) ──
  IF p_token IS NULL
     OR LENGTH(p_token) != 32
     OR p_token !~ '^[a-f0-9]{32}$'
  THEN
    RETURN json_build_object('error', 'invalid_token');
  END IF;

  -- ── Step 2: Look up the sector by token ──
  SELECT s.id
  INTO v_sector_id
  FROM sectors s
  WHERE s.public_token = p_token
    AND s.deleted_at IS NULL;

  IF v_sector_id IS NULL THEN
    RETURN json_build_object('error', 'not_found');
  END IF;

  -- ── Step 3: Build the full response with ONLY safe public fields ──
  SELECT json_build_object(
    'sector', (
      SELECT json_build_object(
        'name',             s.name,
        'number',           s.number,
        'area_ha',          s.area_ha,
        'latitude',         s.latitude,
        'longitude',        s.longitude,
        'production_chain', pc.name
      )
      FROM sectors s
      LEFT JOIN production_chain pc ON pc.id = s.production_chain_id
      WHERE s.id = v_sector_id
    ),
    'batches', COALESCE((
      SELECT json_agg(
        json_build_object(
          'id',         b.id,
          'culture',    b.culture,
          'start_date', b.start_date,
          'end_date',   b.end_date,
          'status',     b.status
        )
        ORDER BY b.start_date DESC
      )
      FROM batches b
      WHERE b.sector_id = v_sector_id
        AND b.deleted_at IS NULL
    ), '[]'::json),
    'pest_controls', COALESCE((
      SELECT json_agg(
        json_build_object(
          'date',                   p.date,
          'product_name',           p.product_name,
          'target_pest',            p.target_pest,
          'dose_l_per_ha',          p.dose_l_per_ha,
          'spray_volume_l_per_ha',  p.spray_volume_l_per_ha,
          'responsible',            p.responsible
        )
        ORDER BY p.date DESC
      )
      FROM pest_control p
      WHERE p.sector_id = v_sector_id
        AND p.deleted_at IS NULL
    ), '[]'::json)
  )
  INTO v_result;

  RETURN v_result;
END;
$$;

-- Allow anon (public page) to call this function
GRANT EXECUTE ON FUNCTION get_public_sector(TEXT) TO anon;
-- Allow authenticated users too (e.g., preview in the Flutter app)
GRANT EXECUTE ON FUNCTION get_public_sector(TEXT) TO authenticated;


-- ════════════════════════════════════════════════════════════════════════
-- 5. HELPER RPC: enable_sector_public_access(sector_id)
--    Called from the Flutter app when a producer wants to make
--    a sector publicly accessible (e.g., generate QR code).
--    Returns the generated 32-char hex token.
-- ════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION enable_sector_public_access(p_sector_id UUID)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_token TEXT;
BEGIN
  -- Verify the caller owns this sector
  IF NOT EXISTS (
    SELECT 1 FROM sectors
    WHERE id = p_sector_id
      AND produtor_id = auth.uid()
      AND deleted_at IS NULL
  ) THEN
    RAISE EXCEPTION 'Unauthorized: you do not own this sector';
  END IF;

  -- If sector already has a token, return the existing one
  SELECT public_token INTO v_token
  FROM sectors
  WHERE id = p_sector_id;

  IF v_token IS NOT NULL THEN
    RETURN v_token;
  END IF;

  -- Generate and assign a new token
  v_token := generate_public_token();

  UPDATE sectors
  SET public_token = v_token,
      updated_at   = NOW()
  WHERE id = p_sector_id
    AND produtor_id = auth.uid();

  RETURN v_token;
END;
$$;

GRANT EXECUTE ON FUNCTION enable_sector_public_access(UUID) TO authenticated;


-- ════════════════════════════════════════════════════════════════════════
-- 6. HELPER RPC: disable_sector_public_access(sector_id)
--    Revokes public access by setting public_token to NULL.
--    The old token immediately stops working.
-- ════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION disable_sector_public_access(p_sector_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Only the owner can revoke
  IF NOT EXISTS (
    SELECT 1 FROM sectors
    WHERE id = p_sector_id
      AND produtor_id = auth.uid()
      AND deleted_at IS NULL
  ) THEN
    RAISE EXCEPTION 'Unauthorized: you do not own this sector';
  END IF;

  UPDATE sectors
  SET public_token = NULL,
      updated_at   = NOW()
  WHERE id = p_sector_id
    AND produtor_id = auth.uid();
END;
$$;

GRANT EXECUTE ON FUNCTION disable_sector_public_access(UUID) TO authenticated;


-- ════════════════════════════════════════════════════════════════════════
-- 7. (OPTIONAL) Generate tokens for existing sectors you want public
--    Uncomment and replace the UUID with your actual sector IDs.
-- ════════════════════════════════════════════════════════════════════════

-- UPDATE sectors
-- SET public_token = generate_public_token()
-- WHERE id = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
--   AND deleted_at IS NULL;

-- To see the generated token:
-- SELECT id, name, public_token FROM sectors WHERE public_token IS NOT NULL;
