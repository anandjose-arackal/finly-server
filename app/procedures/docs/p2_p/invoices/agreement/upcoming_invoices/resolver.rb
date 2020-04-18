class Docs::P2P::Invoices::Agreement::UpcomingInvoices::Resolver < Resolver::API

  # Not assigning the entity as this supports general and rental invoices
  # entity GeneralInvoice

  def load(params)
    case params[:invoice_type].to_s
    when 'general'
      load_general_invoices params
    when 'rental'
      load_rental_invoices params
    else
      load_rental_invoices params
    end
  end

  def load_rental_invoices(params)
    one_time_ri_invoices = user.company.rental_invoices.where(billing_type_id: BillingType.id_for(:one_time)).where("start_date <= ? AND end_date >= ? AND payment_agreement_upcoming_date <= ?", Date.today, Date.today, Date.today).where(is_payment_agreement_upcoming_invoice: true) rescue RentalInvoice.none
    fixed_periodic_ri_invoices = user.company.fixed_periodic_rental_invoices.where(billing_type_id: BillingType.id_for(:fixed_periodic), is_payment_agreement_upcoming_invoice: true).where("payment_agreement_upcoming_date <= ?", Date.today).where(fixed_periodic_template: true) rescue RentalInvoice.none
    one_time_ri_invoices.or(fixed_periodic_ri_invoices)
  end

  def load_general_invoices(params)
    one_time_gi_invoices = user.company.general_invoices.where(billing_type_id: BillingType.id_for(:one_time)).where("start_date <= ? AND end_date >= ? AND payment_agreement_upcoming_date <= ?", Date.today, Date.today, Date.today).where(is_payment_agreement_upcoming_invoice: true) rescue GeneralInvoice.none
    fixed_periodic_gi_invoices = user.company.fixed_periodic_general_invoices.where(billing_type_id: BillingType.id_for(:fixed_periodic), is_payment_agreement_upcoming_invoice: true).where("payment_agreement_upcoming_date <= ?", Date.today).where(fixed_periodic_template: true) rescue GeneralInvoice.none
    one_time_gi_invoices.or(fixed_periodic_gi_invoices)
  end


end