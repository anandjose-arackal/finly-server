class PaymentAgreements::AllUpcomingInvoices < PaymentAgreements::Base
  attr_accessor :invoices, :payment_agreement, :beneficiary_payments, :security_deposits, :general_invoices, :rental_invoices, :policies

  def init
  end

  def validate

  end

  def process 
    self.general_invoices = user.company.general_invoices.where.not(billing_type_id: BillingType.id_for(:variable_periodic)).where("start_date <= ? AND end_date >= ? AND payment_agreement_upcoming_date <= ?", Date.today, Date.today, Date.today).where(is_payment_agreement_upcoming_invoice: true) rescue Invoice.none
    self.rental_invoices = user.company.rental_invoices.where.not(billing_type_id: BillingType.id_for(:variable_periodic)).where("start_date <= ? AND end_date >= ?  AND payment_agreement_upcoming_date <= ?", Date.today, Date.today, Date.today).where(is_payment_agreement_upcoming_invoice: true) rescue Invoice.none

    initiating_user = self.payment_agreement.present? ? payment_agreement.creator : user
    self.policies = Policy::VendorPayments::Index.(initiating_user, params).policies
  end

  def success
    params[:general_invoices] = self.general_invoices
    params[:rental_invoices] = self.rental_invoices
    params[:policies] = self.policies
    PaymentAgreements::AllUpcomingInvoices::AllUpcomingInvoicesPresenter.new(user, params, messages)    
  end

  class PaymentAgreements::AllUpcomingInvoices::AllUpcomingInvoicesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoices, :general_invoices, :rental_invoices, :policies

    def init
      self.general_invoices = params[:general_invoices]
      self.rental_invoices = params[:rental_invoices]
      self.policies = params[:policies]
    end
  end

end