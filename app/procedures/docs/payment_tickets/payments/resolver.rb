class Docs::PaymentTickets::Payments::Resolver < Docs::PaymentTickets::Resolver

  entity Payment

  def load(params)
    payment_tickets = super(params)
    Payment.where("payment_order_id IN (#{payment_tickets.select('payment_order_id').to_sql})")
  end

end