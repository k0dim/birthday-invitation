app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    commit: process.env.GIT_COMMIT || 'unknown',
    tag: process.env.GIT_TAG || 'none',
    deployed_by: process.env.DEPLOYED_BY || 'github-actions',
    timestamp: new Date().toISOString()
  })
})
