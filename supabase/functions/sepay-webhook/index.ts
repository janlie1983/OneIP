import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const apiKey =
    req.headers.get('apikey') ||
    req.headers.get('Authorization')?.replace('Bearer ', '')
  if (apiKey !== Deno.env.get('SEPAY_API_KEY')) {
    return new Response('Unauthorized', { status: 401 })
  }

  const payload = await req.json()
  const { transferAmount, description, transferType, referenceCode } = payload

  if (transferType !== 'in') {
    return new Response('OK', { status: 200 })
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  )

  // Find pending payment whose transfer_code appears in description
  const searchCode = referenceCode ?? description
  const { data: payments } = await supabase
    .from('pending_payments')
    .select('*')
    .eq('status', 'pending')

  const payment = payments?.find(
    (p: { transfer_code: string }) =>
      description?.includes(p.transfer_code) ||
      referenceCode?.includes(p.transfer_code),
  )

  if (!payment) {
    return new Response('Payment not found', { status: 200 })
  }

  if (transferAmount < payment.amount_vnd) {
    return new Response('Insufficient amount', { status: 200 })
  }

  await supabase
    .from('pending_payments')
    .update({ status: 'success' })
    .eq('id', payment.id)

  if (payment.payment_type === 'subscription') {
    const periodEnd = new Date()
    periodEnd.setMonth(periodEnd.getMonth() + 1)

    await supabase.from('subscriptions').upsert({
      user_id: payment.user_id,
      plan: payment.plan,
      status: 'active',
      payment_provider: 'vnpay',
      amount_vnd: payment.amount_vnd,
      current_period_start: new Date().toISOString(),
      current_period_end: periodEnd.toISOString(),
    })
  }

  if (payment.payment_type === 'ppv') {
    await supabase.from('ppv_access').upsert({
      user_id: payment.user_id,
      content_id: payment.content_id,
      expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
    })
  }

  return new Response(JSON.stringify({ success: true }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  })
})
