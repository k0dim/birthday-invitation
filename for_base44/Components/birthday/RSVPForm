import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { CheckCircle2, Send } from 'lucide-react';
import { base44 } from '@/api/base44Client';

export default function RSVPForm() {
  const [formData, setFormData] = useState({
    name: '',
    phone: '',
    attending: 'yes',
    message: ''
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSubmitted, setIsSubmitted] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);

    try {
      await base44.entities.Guest.create(formData);
      
      // Send email notification
      const attendingText = formData.attending === 'yes' ? '✅ Да, приду!' : 
                           formData.attending === 'maybe' ? '🤔 Возможно' : 
                           '❌ Не смогу';
      
      const emailBody = `
Новое подтверждение участия на День рождения!

Имя: ${formData.name}
Телефон: ${formData.phone || 'Не указан'}
Участие: ${attendingText}
Сообщение: ${formData.message || 'Нет сообщения'}

---
Уведомление с сайта приглашения
      `;
      
      await base44.integrations.Core.SendEmail({
        to: 'kond.01.163@gmail.com',
        subject: `🎉 Новый ответ на приглашение от ${formData.name}`,
        body: emailBody
      });
      
      setIsSubmitted(true);
      setFormData({ name: '', phone: '', attending: 'yes', message: '' });
    } catch (error) {
      console.error('Error submitting RSVP:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  if (isSubmitted) {
    return (
      <section id="rsvp" className="py-20 px-6 bg-white">
        <div className="max-w-2xl mx-auto">
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.6 }}
            className="text-center bg-gradient-to-br from-emerald-50 to-amber-50 rounded-3xl p-12 shadow-xl"
          >
            <div className="inline-flex items-center justify-center w-20 h-20 bg-emerald-100 rounded-full mb-6">
              <CheckCircle2 className="w-10 h-10 text-emerald-600" />
            </div>
            <h3 className="text-4xl font-bold text-emerald-900 mb-4">
              Спасибо!
            </h3>
            <p className="text-xl text-gray-700 mb-8">
              Ваш ответ получен. Жду встречи! 🎉
            </p>
            <Button
              onClick={() => setIsSubmitted(false)}
              variant="outline"
              className="border-2 border-emerald-600 text-emerald-700 hover:bg-emerald-50"
            >
              Отправить еще один ответ
            </Button>
          </motion.div>
        </div>
      </section>
    );
  }

  return (
    <section id="rsvp" className="py-20 px-6 bg-white">
      <div className="max-w-2xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
          className="text-center mb-12"
        >
          <h2 className="text-5xl md:text-6xl font-bold text-emerald-900 mb-6">
            Подтверди участие
          </h2>
          <p className="text-xl text-gray-600">
            Буду рад видеть тебя на празднике!
          </p>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8, delay: 0.2 }}
          className="bg-gradient-to-br from-emerald-50 to-amber-50 rounded-3xl p-8 md:p-12 shadow-xl"
        >
          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <Label htmlFor="name" className="text-lg font-semibold text-emerald-900 mb-2 block">
                Твоё имя *
              </Label>
              <Input
                id="name"
                type="text"
                required
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                placeholder="Как тебя зовут?"
                className="h-14 text-lg border-2 border-emerald-200 focus:border-emerald-500 rounded-xl"
              />
            </div>

            <div>
              <Label htmlFor="phone" className="text-lg font-semibold text-emerald-900 mb-2 block">
                Телефон
              </Label>
              <Input
                id="phone"
                type="tel"
                value={formData.phone}
                onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                placeholder="+7 (___) ___-__-__"
                className="h-14 text-lg border-2 border-emerald-200 focus:border-emerald-500 rounded-xl"
              />
            </div>

            <div>
              <Label className="text-lg font-semibold text-emerald-900 mb-3 block">
                Придёшь?
              </Label>
              <div className="grid grid-cols-3 gap-3">
                {[
                  { value: 'yes', label: 'Да! 🎉', color: 'emerald' },
                  { value: 'maybe', label: 'Возможно 🤔', color: 'amber' },
                  { value: 'no', label: 'Не смогу 😔', color: 'gray' }
                ].map((option) => (
                  <button
                    key={option.value}
                    type="button"
                    onClick={() => setFormData({ ...formData, attending: option.value })}
                    className={`py-4 px-3 rounded-xl text-base font-semibold transition-all duration-300 border-2 ${
                      formData.attending === option.value
                        ? `bg-${option.color}-600 text-white border-${option.color}-600 shadow-lg scale-105`
                        : `bg-white text-gray-700 border-gray-300 hover:border-${option.color}-400`
                    }`}
                  >
                    {option.label}
                  </button>
                ))}
              </div>
            </div>

            <div>
              <Label htmlFor="message" className="text-lg font-semibold text-emerald-900 mb-2 block">
                Пожелания или комментарии
              </Label>
              <Textarea
                id="message"
                value={formData.message}
                onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                placeholder="Есть что сказать?"
                rows={4}
                className="text-lg border-2 border-emerald-200 focus:border-emerald-500 rounded-xl resize-none"
              />
            </div>

            <Button
              type="submit"
              disabled={isSubmitting}
              className="w-full h-14 bg-emerald-600 hover:bg-emerald-700 text-white text-lg font-semibold rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 transform hover:scale-105 flex items-center justify-center gap-2"
            >
              {isSubmitting ? (
                'Отправка...'
              ) : (
                <>
                  <Send className="w-5 h-5" />
                  Отправить ответ
                </>
              )}
            </Button>
          </form>
        </motion.div>
      </div>
    </section>
  );
}