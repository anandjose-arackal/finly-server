class Docs::P2P::Invoices::InvoiceLineItems::Resolver < Resolver::API
  entity InvoiceLineItem

  # Adding this skip filtering for child items.
  def self.is_items_resolver?
    true
  end

  def load(params)
    invoices = Resolver::Router.dispatch('invoices.default', { params: params, current_user: user })
    InvoiceLineItem.where(parent_type: 'Invoice').where("parent_id IN (#{invoices.select('id').to_sql})").order(parent_id: :asc)
  end
end
