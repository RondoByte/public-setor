<template>
  <div class="min-h-screen bg-stone-50 font-sans">

    <!-- ═══════════════════ LOADING ═══════════════════ -->
    <div v-if="loading" class="flex flex-col items-center justify-center min-h-screen gap-5">
      <!-- Animated leaf spinner -->
      <div class="relative flex items-center justify-center">
        <div class="w-20 h-20 rounded-full border-4 border-brand-200 border-t-brand-500 animate-spin"></div>
        <!-- Sprout / seedling icon -->
        <svg class="absolute w-8 h-8 text-brand-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M7 20h10" /><path d="M10 20c5.5-2.5 8-7 8-14" /><path d="M9.5 9.4c1.1.8 1.8 2.2 2.3 3.7-2 .4-3.5.4-4.8-.3-1.2-.6-2.3-1.9-3-4.2 2.8-.5 4.4 0 5.5.8z" /><path d="M14.1 6a7 7 0 0 0-1.1 4c1.9-.1 3.3-.6 4.3-1.4 1-1 1.6-2.3 1.7-4.6-2.7.1-4 1-4.9 2z" />
        </svg>
      </div>
      <p class="text-brand-700 font-medium text-lg tracking-wide">Carregando dados do setor…</p>
    </div>

    <!-- ═══════════════════ ERROR ═══════════════════ -->
    <div v-else-if="error" class="flex flex-col items-center justify-center min-h-screen px-4 gap-6">
      <div class="bg-white rounded-2xl shadow-elevated p-8 max-w-md text-center space-y-4">
        <div class="w-16 h-16 mx-auto rounded-full bg-red-50 flex items-center justify-center">
          <i class="pi pi-exclamation-triangle text-3xl text-red-400"></i>
        </div>
        <h2 class="text-xl font-semibold text-gray-800">Erro ao carregar</h2>
        <!-- SECURITY: Generic error message — never expose internal details -->
        <p class="text-gray-500 text-sm leading-relaxed">{{ error }}</p>
        <button
          @click="$router.go(0)"
          class="mt-2 inline-flex items-center gap-2 px-5 py-2.5 bg-brand-500 hover:bg-brand-600 text-white
                 rounded-lg text-sm font-medium transition-colors"
        >
          <i class="pi pi-refresh"></i> Tentar novamente
        </button>
      </div>
    </div>

    <!-- ═══════════════════ NOT FOUND ═══════════════════ -->
    <div v-else-if="!sector" class="flex flex-col items-center justify-center min-h-screen px-4 gap-6">
      <div class="bg-white rounded-2xl shadow-elevated p-8 max-w-md text-center space-y-4">
        <div class="w-16 h-16 mx-auto rounded-full bg-brand-50 flex items-center justify-center">
          <i class="pi pi-search text-3xl text-brand-300"></i>
        </div>
        <h2 class="text-xl font-semibold text-gray-800">Setor não encontrado</h2>
        <p class="text-gray-500 text-sm leading-relaxed">
          O setor solicitado não existe ou o link é inválido.<br />
          Verifique o link e tente novamente.
        </p>
      </div>
    </div>

    <!-- ═══════════════════ MAIN CONTENT ═══════════════════ -->
    <template v-else>

      <!-- ── Top navigation bar ── -->
      <nav class="sticky top-0 z-50 bg-brand-950/95 backdrop-blur-md border-b border-brand-800/50">
        <div class="max-w-5xl mx-auto px-4 sm:px-6 h-14 flex items-center justify-between">
          <div class="flex items-center gap-2.5">
            <img src="/logo-safra-na-mao.png" alt="Safra na Mão" class="w-7 h-7" />
            <span class="text-white font-bold text-base tracking-tight">Safra na Mão</span>
          </div>
          <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-accent-400/20 text-accent-300 text-xs font-semibold uppercase tracking-wider">
            <i class="pi pi-verified text-[10px]"></i>
            Rastreabilidade
          </span>
        </div>
      </nav>

      <!-- ── Hero section ── -->
      <header class="bg-gradient-to-br from-brand-950 via-brand-800 to-brand-600 text-white relative overflow-hidden">
        <!-- Subtle pattern overlay -->
        <div class="absolute inset-0 opacity-[0.04]" style="background-image: url('data:image/svg+xml,%3Csvg width=&quot;60&quot; height=&quot;60&quot; viewBox=&quot;0 0 60 60&quot; xmlns=&quot;http://www.w3.org/2000/svg&quot;%3E%3Cg fill=&quot;none&quot; fill-rule=&quot;evenodd&quot;%3E%3Cg fill=&quot;%23ffffff&quot; fill-opacity=&quot;1&quot;%3E%3Cpath d=&quot;M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z&quot;/%3E%3C/g%3E%3C/g%3E%3C/svg%3E');"></div>

        <div class="relative max-w-5xl mx-auto px-4 sm:px-6 py-10 md:py-14">
          <div class="animate-fade-in-up space-y-4">
            <!-- Breadcrumb -->
            <div class="flex items-center gap-2 text-brand-300/80 text-xs font-medium uppercase tracking-widest">
              <i class="pi pi-home text-[10px]"></i>
              <span>Rastreabilidade</span>
              <i class="pi pi-angle-right text-[10px]"></i>
              <span>Setor</span>
            </div>

            <!-- Sector name (escaped via Vue's {{ }} — safe from XSS) -->
            <h1 class="text-3xl md:text-4xl font-extrabold leading-tight tracking-tight">
              {{ sector.name }}
            </h1>

            <!-- Meta badges row -->
            <div class="flex flex-wrap items-center gap-2.5 pt-1">
              <!-- Production chain badge -->
              <span
                v-if="chainName"
                class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/15 text-white/90
                       text-xs font-medium backdrop-blur-sm border border-white/10"
              >
                <i class="pi pi-sitemap text-[10px]"></i>
                {{ chainName }}
              </span>
              <!-- Sector number -->
              <span
                class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/15 text-white/90
                       text-xs font-medium backdrop-blur-sm border border-white/10"
              >
                <i class="pi pi-hashtag text-[10px]"></i>
                Setor {{ sector.number }}
              </span>
              <!-- Area badge -->
              <span
                v-if="sector.area_ha != null"
                class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/15 text-white/90
                       text-xs font-medium backdrop-blur-sm border border-white/10"
              >
                <i class="pi pi-stop text-[10px]"></i>
                {{ sector.area_ha }} ha
              </span>
              <!-- Coordinates badge -->
              <span
                v-if="hasCoordinates"
                class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/15 text-white/90
                       text-xs font-medium backdrop-blur-sm border border-white/10"
              >
                <i class="pi pi-map-marker text-[10px]"></i>
                {{ Number(sector.latitude).toFixed(4) }}, {{ Number(sector.longitude).toFixed(4) }}
              </span>
            </div>

            <!-- Date -->
            <p class="text-brand-300/70 text-sm pt-1">
              <i class="pi pi-calendar mr-1.5 text-xs"></i>{{ currentDate }}
            </p>
          </div>
        </div>
      </header>

      <!-- ── Body content ── -->
      <main class="max-w-5xl mx-auto px-4 sm:px-6 py-8 stagger-children space-y-8">

        <!-- ── Map section ── -->
        <section v-if="hasCoordinates" class="bg-white rounded-2xl shadow-card overflow-hidden border border-gray-100">
          <!-- Map header -->
          <div class="px-5 py-4 border-b border-gray-100 flex items-center justify-between">
            <div class="flex items-center gap-2.5">
              <div class="w-8 h-8 rounded-lg bg-brand-50 flex items-center justify-center">
                <i class="pi pi-map text-brand-500 text-sm"></i>
              </div>
              <div>
                <h2 class="text-sm font-semibold text-gray-800">Localização</h2>
                <p class="text-xs text-gray-400">Coordenadas geográficas do setor</p>
              </div>
            </div>
            <a
              :href="googleMapsUrl"
              target="_blank"
              rel="noopener noreferrer"
              class="inline-flex items-center gap-1.5 px-3.5 py-1.5 bg-brand-500 hover:bg-brand-600
                     text-white rounded-lg text-xs font-medium transition-all hover:shadow-md"
            >
              <i class="pi pi-external-link text-[10px]"></i>
              Google Maps
            </a>
          </div>
          <!-- Map container -->
          <div ref="mapContainer" class="w-full h-72 md:h-[420px]"></div>
        </section>

        <!-- No coordinates notice -->
        <div
          v-else
          class="bg-amber-50 border border-amber-200 rounded-2xl px-5 py-4 flex items-center gap-3"
        >
          <div class="w-8 h-8 rounded-lg bg-amber-100 flex items-center justify-center shrink-0">
            <i class="pi pi-info-circle text-amber-500 text-sm"></i>
          </div>
          <p class="text-sm text-amber-700">
            Este setor não possui coordenadas cadastradas — mapa indisponível.
          </p>
        </div>

        <!-- ── Sector overview cards ── -->
        <section>
          <div class="flex items-center gap-2.5 mb-4">
            <div class="w-8 h-8 rounded-lg bg-brand-50 flex items-center justify-center">
              <i class="pi pi-th-large text-brand-500 text-sm"></i>
            </div>
            <h2 class="text-base font-semibold text-gray-800">Informações do Setor</h2>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <!-- Card: Production Chain -->
            <div class="bg-white rounded-xl border border-gray-100 shadow-card p-5 hover:shadow-card-hover transition-shadow">
              <div class="flex items-center gap-3 mb-3">
                <div class="w-9 h-9 rounded-lg bg-emerald-50 flex items-center justify-center">
                  <i class="pi pi-sitemap text-emerald-500"></i>
                </div>
                <span class="text-xs font-medium text-gray-400 uppercase tracking-wider">Cadeia Produtiva</span>
              </div>
              <p class="text-lg font-bold text-gray-800">{{ chainName || '—' }}</p>
            </div>

            <!-- Card: Sector Number -->
            <div class="bg-white rounded-xl border border-gray-100 shadow-card p-5 hover:shadow-card-hover transition-shadow">
              <div class="flex items-center gap-3 mb-3">
                <div class="w-9 h-9 rounded-lg bg-blue-50 flex items-center justify-center">
                  <i class="pi pi-hashtag text-blue-500"></i>
                </div>
                <span class="text-xs font-medium text-gray-400 uppercase tracking-wider">Número do Setor</span>
              </div>
              <p class="text-lg font-bold text-gray-800">{{ sector.number }}</p>
            </div>

            <!-- Card: Area -->
            <div class="bg-white rounded-xl border border-gray-100 shadow-card p-5 hover:shadow-card-hover transition-shadow">
              <div class="flex items-center gap-3 mb-3">
                <div class="w-9 h-9 rounded-lg bg-amber-50 flex items-center justify-center">
                  <i class="pi pi-stop text-amber-500"></i>
                </div>
                <span class="text-xs font-medium text-gray-400 uppercase tracking-wider">Área</span>
              </div>
              <p class="text-lg font-bold text-gray-800">
                {{ sector.area_ha != null ? sector.area_ha + ' ha' : '—' }}
              </p>
            </div>
          </div>
        </section>

        <!-- ── Batches / Cultures ── -->
        <section>
          <div class="flex items-center gap-2.5 mb-4">
            <div class="w-8 h-8 rounded-lg bg-brand-50 flex items-center justify-center">
              <i class="pi pi-box text-brand-500 text-sm"></i>
            </div>
            <h2 class="text-base font-semibold text-gray-800">Lotes de Produção</h2>
            <span class="ml-auto text-xs font-semibold text-brand-500 bg-brand-50 px-2.5 py-0.5 rounded-full">
              {{ batches.length }}
            </span>
          </div>

          <!-- Empty batches -->
          <div
            v-if="batches.length === 0"
            class="bg-white rounded-xl border border-gray-100 shadow-card p-6 text-center"
          >
            <div class="w-12 h-12 mx-auto rounded-full bg-gray-50 flex items-center justify-center mb-3">
              <i class="pi pi-inbox text-xl text-gray-300"></i>
            </div>
            <p class="text-sm text-gray-400">Nenhum lote registrado neste setor.</p>
          </div>

          <!-- Batch cards -->
          <div v-else class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div
              v-for="batch in batches"
              :key="batch.id"
              class="bg-white rounded-xl border border-gray-100 shadow-card p-5 hover:shadow-card-hover
                     transition-shadow flex flex-col gap-3"
            >
              <div class="flex items-start justify-between">
                <div class="flex items-center gap-2.5">
                  <div class="w-9 h-9 rounded-lg bg-brand-50 flex items-center justify-center">
                    <!-- Wheat / grain icon -->
                    <svg class="w-5 h-5 text-brand-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M2 22 16 8" /><path d="M3.47 12.53 5 11l1.53 1.53a3.5 3.5 0 0 1 0 4.94L5 19l-1.53-1.53a3.5 3.5 0 0 1 0-4.94Z" /><path d="M7.47 8.53 9 7l1.53 1.53a3.5 3.5 0 0 1 0 4.94L9 15l-1.53-1.53a3.5 3.5 0 0 1 0-4.94Z" /><path d="M11.47 4.53 13 3l1.53 1.53a3.5 3.5 0 0 1 0 4.94L13 11l-1.53-1.53a3.5 3.5 0 0 1 0-4.94Z" /><path d="M20 2h2v2a4 4 0 0 1-4 4h-2V6a4 4 0 0 1 4-4Z" /><path d="M11.47 17.47 13 19l-1.53 1.53a3.5 3.5 0 0 1-4.94 0L5 19l1.53-1.53a3.5 3.5 0 0 1 4.94 0Z" /><path d="M15.47 13.47 17 15l-1.53 1.53a3.5 3.5 0 0 1-4.94 0L9 15l1.53-1.53a3.5 3.5 0 0 1 4.94 0Z" /><path d="M19.47 9.47 21 11l-1.53 1.53a3.5 3.5 0 0 1-4.94 0L13 11l1.53-1.53a3.5 3.5 0 0 1 4.94 0Z" />
                    </svg>
                  </div>
                  <div>
                    <p class="font-semibold text-gray-800 text-sm">{{ batch.culture }}</p>
                    <p class="text-xs text-gray-400 mt-0.5">
                      {{ formatDate(batch.start_date) }}
                      <template v-if="batch.end_date">
                        → {{ formatDate(batch.end_date) }}
                      </template>
                    </p>
                  </div>
                </div>
                <!-- Status badge -->
                <span
                  :class="[
                    'inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[11px] font-semibold uppercase tracking-wide',
                    batch.status === 'active'
                      ? 'bg-emerald-50 text-emerald-600 ring-1 ring-emerald-200'
                      : 'bg-gray-100 text-gray-500 ring-1 ring-gray-200'
                  ]"
                >
                  <span
                    :class="[
                      'w-1.5 h-1.5 rounded-full',
                      batch.status === 'active' ? 'bg-emerald-400' : 'bg-gray-400'
                    ]"
                  ></span>
                  {{ batch.status === 'active' ? 'Ativo' : 'Encerrado' }}
                </span>
              </div>
            </div>
          </div>
        </section>

        <!-- ── Pest Control Table ── -->
        <section>
          <div class="flex items-center gap-2.5 mb-4">
            <div class="w-8 h-8 rounded-lg bg-brand-50 flex items-center justify-center">
              <i class="pi pi-shield text-brand-500 text-sm"></i>
            </div>
            <div>
              <h2 class="text-base font-semibold text-gray-800">Controle Fitossanitário</h2>
              <p class="text-xs text-gray-400 mt-0.5">Histórico de aplicações de defensivos</p>
            </div>
            <span class="ml-auto text-xs font-semibold text-brand-500 bg-brand-50 px-2.5 py-0.5 rounded-full">
              {{ pestControls.length }}
            </span>
          </div>

          <!-- Empty pest control -->
          <div
            v-if="pestControls.length === 0"
            class="bg-white rounded-xl border border-gray-100 shadow-card p-6 text-center"
          >
            <div class="w-12 h-12 mx-auto rounded-full bg-gray-50 flex items-center justify-center mb-3">
              <i class="pi pi-check-circle text-xl text-gray-300"></i>
            </div>
            <p class="text-sm text-gray-400">Nenhum registro de controle fitossanitário.</p>
          </div>

          <!-- Data table -->
          <div
            v-else
            class="bg-white rounded-2xl shadow-card overflow-hidden border border-gray-100"
          >
            <DataTable
              :value="pestControls"
              stripedRows
              responsiveLayout="scroll"
              :paginator="pestControls.length > 10"
              :rows="10"
              :rowsPerPageOptions="[5, 10, 25]"
              paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink RowsPerPageDropdown"
              class="setor-table"
            >
              <Column header="Data" sortable style="min-width: 100px">
                <template #body="{ data }">
                  <span class="font-medium text-gray-700 text-sm">{{ formatDate(data.date) }}</span>
                </template>
              </Column>

              <Column header="Produto" sortable style="min-width: 160px">
                <template #body="{ data }">
                  <div>
                    <span class="font-medium text-gray-800 text-sm">{{ data.product_name }}</span>
                    <span
                      v-if="data.target_pest"
                      class="block text-xs text-gray-400 mt-0.5"
                    >
                      Alvo: {{ data.target_pest }}
                    </span>
                  </div>
                </template>
              </Column>

              <Column header="Dose (L/ha)" style="min-width: 100px">
                <template #body="{ data }">
                  <span class="text-sm text-gray-600">
                    {{ data.dose_l_per_ha != null ? data.dose_l_per_ha : '—' }}
                  </span>
                </template>
              </Column>

              <Column header="Vol. Calda (L/ha)" style="min-width: 120px">
                <template #body="{ data }">
                  <span class="text-sm text-gray-600">
                    {{ data.spray_volume_l_per_ha != null ? data.spray_volume_l_per_ha : '—' }}
                  </span>
                </template>
              </Column>

              <Column header="Responsável" style="min-width: 130px">
                <template #body="{ data }">
                  <div v-if="data.responsible" class="flex items-center gap-2">
                    <div class="w-6 h-6 rounded-full bg-brand-100 flex items-center justify-center">
                      <span class="text-[10px] font-bold text-brand-600">
                        {{ data.responsible.charAt(0).toUpperCase() }}
                      </span>
                    </div>
                    <span class="text-sm text-gray-700">{{ data.responsible }}</span>
                  </div>
                  <span v-else class="text-sm text-gray-400">—</span>
                </template>
              </Column>
            </DataTable>
          </div>
        </section>

      </main>

      <!-- ── Footer ── -->
      <footer class="bg-brand-950 text-white/60 mt-12">
        <div class="max-w-5xl mx-auto px-4 sm:px-6 py-8">
          <div class="flex flex-col sm:flex-row items-center justify-between gap-4">
            <div class="flex items-center gap-2.5">
              <img src="/logo-safra-na-mao.png" alt="Safra na Mão" class="w-5 h-5" />
              <span class="text-white font-bold text-sm tracking-tight">Safra na Mão</span>
            </div>
            <p class="text-xs text-center sm:text-right leading-relaxed max-w-md">
              Dados de rastreabilidade gerados pelo sistema Safra na Mão.
              As informações são declaratórias e de responsabilidade do produtor rural.
            </p>
          </div>
          <div class="mt-6 pt-4 border-t border-white/10 text-center text-xs text-white/30">
            &copy; {{ new Date().getFullYear() }} Safra na Mão — Caderno de campo digital
          </div>
        </div>
      </footer>

    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from '../lib/supabase'

// PrimeVue components
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'

// Leaflet
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'

// ── Route ──
const route = useRoute()

// ── Reactive state ──
const loading = ref(true)
const error = ref(null)
const sector = ref(null)
const batches = ref([])
const pestControls = ref([])
const mapContainer = ref(null)

let map = null // Leaflet instance (non-reactive)

// ══════════════════════════════════════════════════════════════════════
// SECURITY: Input validation helpers
// ══════════════════════════════════════════════════════════════════════

/**
 * Validate that the token is a 32-character hex string.
 * This prevents injection and avoids unnecessary DB round-trips.
 */
function isValidToken(token) {
  if (!token || typeof token !== 'string') return false
  return /^[a-f0-9]{32}$/.test(token)
}

/**
 * Sanitize a plain-text string for safe use in innerHTML contexts (e.g., Leaflet popups).
 * Escapes HTML entities to prevent XSS.
 */
function escapeHtml(str) {
  if (!str) return ''
  const div = document.createElement('div')
  div.appendChild(document.createTextNode(str))
  return div.innerHTML
}

// ── Computed properties ──

/** Public token from ?token= query parameter */
const publicToken = computed(() => route.query.token)

/** True when sector has valid latitude + longitude */
const hasCoordinates = computed(
  () => sector.value?.latitude != null && sector.value?.longitude != null
)

/** Formatted current date in pt-BR */
const currentDate = computed(() =>
  new Date().toLocaleDateString('pt-BR', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
)

/** Google Maps URL */
const googleMapsUrl = computed(() => {
  if (!hasCoordinates.value) return '#'
  const lat = Number(sector.value.latitude)
  const lng = Number(sector.value.longitude)
  // Validate coordinates are reasonable numbers
  if (isNaN(lat) || isNaN(lng) || lat < -90 || lat > 90 || lng < -180 || lng > 180) return '#'
  return `https://maps.google.com/?q=${lat},${lng}`
})

/** Resolved production chain name */
const chainName = computed(() => {
  if (!sector.value) return ''
  const chain = sector.value.production_chain
  if (typeof chain === 'string') return chain
  return ''
})

// ══════════════════════════════════════════════════════════════════════
// DATA FETCHING — Secure approach using RPC function
// ══════════════════════════════════════════════════════════════════════

async function fetchData() {
  const token = publicToken.value

  // SECURITY: Validate token format before any DB call
  if (!token) {
    error.value = 'Link inválido. Nenhum token de acesso fornecido.'
    loading.value = false
    return
  }

  if (!isValidToken(token)) {
    error.value = 'Link inválido. O token de acesso não é válido.'
    loading.value = false
    return
  }

  try {
    // Call the secure RPC function that validates the token server-side
    // and returns ONLY safe public fields
    const { data, error: rpcError } = await supabase.rpc('get_public_sector', {
      p_token: token,
    })

    if (rpcError) {
      // SECURITY: Do not expose internal error details
      throw rpcError
    }

    // The RPC returns a JSON object with { sector, batches, pest_controls }
    // or { error: 'not_found' } / { error: 'invalid_token' }
    if (!data || data.error === 'not_found' || data.error === 'invalid_token') {
      sector.value = null
      loading.value = false
      return
    }

    sector.value = data.sector
    batches.value = data.batches || []
    pestControls.value = data.pest_controls || []
  } catch (err) {
    // SECURITY: Log minimal info, never expose to user
    if (import.meta.env.DEV) {
      console.error('[DEV] Fetch error:', err?.message)
    }
    error.value = 'Não foi possível carregar os dados. Verifique o link e tente novamente.'
  } finally {
    loading.value = false
  }
}

// ── Leaflet map initialization ──

function initMap() {
  if (!hasCoordinates.value || !mapContainer.value) return

  const lat = Number(sector.value.latitude)
  const lng = Number(sector.value.longitude)

  // SECURITY: Validate coordinates before using
  if (isNaN(lat) || isNaN(lng) || lat < -90 || lat > 90 || lng < -180 || lng > 180) return

  map = L.map(mapContainer.value, {
    scrollWheelZoom: false, // Prevent accidental scroll-zoom on mobile
  }).setView([lat, lng], 14)

  // OpenStreetMap tiles
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    maxZoom: 19,
  }).addTo(map)

  // Custom marker icon
  const markerIcon = L.icon({
    iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
    iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
    shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
    iconSize: [25, 41],
    iconAnchor: [12, 41],
    popupAnchor: [1, -34],
    shadowSize: [41, 41],
  })

  // SECURITY: Escape sector name to prevent XSS in popup HTML
  const safeName = escapeHtml(sector.value.name)
  const areaLine = sector.value.area_ha != null
    ? `<br><span style="color:#666">Área:</span> <b>${escapeHtml(String(sector.value.area_ha))} ha</b>`
    : ''

  L.marker([lat, lng], { icon: markerIcon })
    .addTo(map)
    .bindPopup(
      `<div style="font-family:Inter,sans-serif;line-height:1.5">
         <strong style="font-size:14px">${safeName}</strong>
         ${areaLine}
       </div>`,
      { maxWidth: 250 }
    )
    .openPopup()

  // Force recalculate after v-if render
  setTimeout(() => map?.invalidateSize(), 200)
}

// ── Helpers ──

/** Format ISO date string → dd/MM/yyyy (pt-BR) */
function formatDate(dateStr) {
  if (!dateStr) return '—'
  const d = new Date(dateStr + 'T00:00:00')
  if (isNaN(d.getTime())) return '—'
  return d.toLocaleDateString('pt-BR')
}

// ── Lifecycle ──

onMounted(async () => {
  await fetchData()
  if (hasCoordinates.value) {
    await nextTick()
    initMap()
  }
})

onUnmounted(() => {
  if (map) {
    map.remove()
    map = null
  }
})
</script>
