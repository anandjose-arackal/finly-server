class Docs::P2P::Invoices::Agreement::UpcomingInvoices::GeneralInvoiceResolver < Docs::P2P::Invoices::Resolver

  def load(params)
    one_time_gi_invoices = user.company.general_invoices.where(billing_type_id: BillingType.id_for(:one_time)).where("start_date <= ? AND end_date >= ? AND payment_agreement_upcoming_date <= ?", Date.today, Date.today, Date.today).where(is_payment_agreement_upcoming_invoice: true) rescue GeneralInvoice.none
    fixed_periodic_gi_invoices = user.company.fixed_periodic_general_invoices.where(billing_type_id: BillingType.id_for(:fixed_periodic), is_payment_agreement_upcoming_invoice: true).where("payment_agreement_upcoming_date <= ?", Date.today).where(fixed_periodic_template: true) rescue GeneralInvoice.none
    one_time_gi_invoices.or(fixed_periodic_gi_invoices)
  end


end