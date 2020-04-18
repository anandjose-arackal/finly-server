class Docs::P2P::Invoices::Agreement::UpcomingInvoices::Policy < ApplicationPolicy

  def create_invoice?
    false
  end

end