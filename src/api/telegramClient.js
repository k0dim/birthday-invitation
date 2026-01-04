// Telegram Bot API клиент
const TELEGRAM_BOT_TOKEN = import.meta.env.VITE_TELEGRAM_BOT_TOKEN || ''
const TELEGRAM_CHAT_ID = import.meta.env.VITE_TELEGRAM_CHAT_ID || ''

export const telegramClient = {
  // Отправка сообщения в Telegram
  async sendMessage(message) {
    if (!TELEGRAM_BOT_TOKEN || !TELEGRAM_CHAT_ID) {
      console.warn('Telegram bot token or chat ID not configured')
      console.log('Mock message:', message)
      return { ok: true } // Возвращаем успех для разработки
    }

    try {
      const response = await fetch(`https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          chat_id: TELEGRAM_CHAT_ID,
          text: message,
          parse_mode: 'HTML',
        }),
      })

      const data = await response.json()
      return data
    } catch (error) {
      console.error('Error sending Telegram message:', error)
      throw error
    }
  },

  // Отправка RSVP уведомления
  async sendRSVPNotification(formData) {
    const attendingText = formData.attending === 'yes' ? '✅ Да, приду!' : 
                         formData.attending === 'maybe' ? '🤔 Возможно' : 
                         '❌ Не смогу'

    const message = `
🎉 <b>Новое подтверждение участия!</b>

👤 <b>Имя:</b> ${formData.name}
📞 <b>Телефон:</b> ${formData.phone || 'Не указан'}
🎯 <b>Участие:</b> ${attendingText}
💭 <b>Сообщение:</b> ${formData.message || 'Нет сообщения'}

📅 <i>Отправлено: ${new Date().toLocaleString('ru-RU')}</i>
    `.trim()

    return this.sendMessage(message)
  },

  // Проверка доступности бота
  async checkBotAvailability() {
    if (!TELEGRAM_BOT_TOKEN || !TELEGRAM_CHAT_ID) {
      return { ok: false, error: 'Bot not configured' }
    }

    try {
      const response = await fetch(`https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe`)
      const data = await response.json()
      return data
    } catch (error) {
      console.error('Error checking bot availability:', error)
      return { ok: false, error: error.message }
    }
  }
}

export default telegramClient