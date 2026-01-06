import express from 'express'
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const app = express()
const PORT = process.env.PORT || 3000
const START_TIME = Date.now()

// ======= ЛОГ СТАРТА =======
console.log('🚀 Starting birthday-invitation')
console.log('📦 NODE_ENV:', process.env.NODE_ENV || 'production')
console.log('🕐 Start time:', new Date().toISOString())
console.log('📁 Working dir:', __dirname)

// ======= VERSION =======
let version = 'unknown'
try {
  const pkg = JSON.parse(
    fs.readFileSync(path.join(__dirname, 'package.json'), 'utf-8')
  )
  version = pkg.version
} catch (e) {
  console.warn('⚠️ Cannot read version from package.json')
}

// ======= HEALTHCHECK =======
app.get('/health', (req, res) => {
  const uptime = Math.floor((Date.now() - START_TIME) / 1000)

  console.log(
    `💚 Healthcheck OK | ip=${req.ip} uptime=${uptime}s`
  )

  res.json({
    status: 'ok',
    uptime,
    version,
    timestamp: new Date().toISOString()
  })
})

// ======= VERSION ENDPOINT =======
app.get('/version', (req, res) => {
  console.log(`📦 Version requested | ${version}`)
  res.json({ version })
})

// ======= STATIC FRONTEND =======
const distPath = path.join(__dirname, 'dist')

if (fs.existsSync(distPath)) {
  console.log('📂 Serving static files from /dist')
  app.use(express.static(distPath))

  app.get('*', (_, res) => {
    res.sendFile(path.join(distPath, 'index.html'))
  })
} else {
  console.warn('⚠️ dist/ not found — frontend not built')
}

// ======= START SERVER =======
app.listen(PORT, () => {
  console.log(`✅ App is running on port ${PORT}`)
})
