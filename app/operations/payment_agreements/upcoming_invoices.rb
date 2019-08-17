class PaymentAgreements::UpcomingInvoices < PaymentAgreements::Base
  attr_accessor :invoices, :payment_agreement, :beneficiary_payments, :security_deposits, :general_invoices, :rental_invoices, :policies

  def init
    id = params[:id] || params[:payment_agreement_id]
    self.payment_agreement = user.company.payment_agreements.find_by_id id
  end

  def validate
    if payment_agreement.blank?
      add_message :error, 'Agreement not found'
      return
    end

    unless payment_agreement.approved? || payment_agreement.auto_approved?
      add_message :error, 'Payment agreement should be approved for raising invoices'
    end
  end

  def process 
    # General and Rental are recurring, use past invoice trail to check if invoice is due
    # self.general_invoices = payment_agreement.general_invoices.where("payment_agreement_upcoming_date <= ?", Date.today).where(is_payment_agreement_upcoming_invoice: true) rescue Invoice.none
    self.general_invoices = payment_agreement.general_invoices.where("start_date <= ? AND end_date >= ?", Date.today, Date.today) rescue Invoice.none
    # self.general_invoices = general_invoices.or(payment_agreement.general_invoices.where(payment_agreement_upcoming_date: nil)) rescue Invoice.none

    # self.rental_invoices = payment_agreement.rental_invoices.where("payment_agreement_upcoming_date <= ?", Date.today).where(is_payment_agreement_upcoming_invoice: true) rescue Invoice.none
    self.rental_invoices = payment_agreement.rental_invoices.where("start_date <= ? AND end_date >= ?", Date.today, Date.today) rescue Invoice.none
    # self.rental_invoices = rental_invoices.or(payment_agreement.rental_invoices.where(payment_agreement_upcoming_date: nil)) rescue Invoice.none

    # self.beneficiary_payments = payment_agreement.beneficiary_payments.where("payment_agreement_upcoming_date <= ?", Date.today) rescue BeneficiaryPayment.none

    # self.security_deposits = payment_agreement.security_deposits.where("payment_agreement_upcoming_date <= ?", Date.today) rescue SecurityDeposit.none

    initiating_user = self.payment_agreement.present? ? payment_agreement.creator : user
    self.policies = Policy::VendorPayments::Index.(initiating_user, params).policies
  end

  def success
    params[:beneficiary_payments] = self.beneficiary_payments
    params[:security_deposits] = self.security_deposits
    params[:general_invoices] = self.general_invoices
    params[:rental_invoices] = self.rental_invoices
    params[:policies] = self.policies
    PaymentAgreements::UpcomingInvoices::UpcomingInvoicesPresenter.new(user, params, messages)    
  end

  class PaymentAgreements::UpcomingInvoices::UpcomingInvoicesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoices, :beneficiary_payments, :security_deposits, :general_invoices, :rental_invoices, :policies

    def init
      self.beneficiary_payments = params[:beneficiary_payments]
      self.security_deposits = params[:security_deposits]
      self.general_invoices = params[:general_invoices]
      self.rental_invoices = params[:rental_invoices]
      self.policies = params[:policies]
    end
  end

end