import { createRouter, createWebHistory } from 'vue-router'
import SetorPage from '../views/SetorPage.vue'

const routes = [
  {
    path: '/setor',
    name: 'setor',
    component: SetorPage,
  },
  {
    // Redirect root to /setor (convenience)
    path: '/',
    redirect: '/setor',
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
