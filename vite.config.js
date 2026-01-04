import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig(({ mode }) => {
  // Загружаем env переменные
  const env = loadEnv(mode, process.cwd(), '')
  
  return {
    plugins: [react()],
    base: '/birthday-invitation/',
    define: {
      // Делаем env переменные доступными в коде
      'process.env': env
    },
    server: {
      port: 3000,
      open: true
    }
  }
})