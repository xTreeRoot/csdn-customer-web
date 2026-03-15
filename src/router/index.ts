import { createRouter, createWebHistory } from 'vue-router'
import UseCodeView from '@/views/UseCodeView.vue'

const routes = [
  {
    path: '/',
    name: 'UseCode',
    component: UseCodeView,
    meta: { title: '使用Code' }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, _from, next) => {
  document.title = to.meta.title as string || '资源下载'
  next()
})

export default router
