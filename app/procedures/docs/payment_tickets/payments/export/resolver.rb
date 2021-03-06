class Docs::PaymentTickets::Payments::Export::Resolver < Resolver::API

  entity Payment

  # Adding this skip filtering for child items.
  def self.is_items_resolver?
    true
  end

  def load(params)
    payment_tickets = Resolver::Router.dispatch('payment_tickets.default', { params: params, current_user: user })
    Payment.where("payments.payment_order_id IN (#{payment_tickets.select('bank_payment_requests.payment_order_id').to_sql})")
  end

end