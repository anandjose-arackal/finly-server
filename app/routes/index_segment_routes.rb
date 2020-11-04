Lookup::Router.draw do
  route "invoices.index.payment_pending", Docs::P2P::Invoices::Views::PendingPayment # Went with singular because plural was already being used by other areas of the app
end