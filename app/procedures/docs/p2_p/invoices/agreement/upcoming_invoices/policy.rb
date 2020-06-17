class Docs::P2P::Invoices::Agreement::UpcomingInvoices::Policy < ApplicationPolicy

  def create_invoice?
    record.is_payment_agreement_upcoming_invoice &&
        record.payment_agreement_upcoming_date <= Date.today &&
        record.payment_agreement.is_agreement_invoice_initiating_user? &&
        record.payment_agreement.approved?
  end

end