class PaymentAgreements::UpcomingInvoices < PaymentAgreements::Base
  attr_accessor :invoices, :payment_agreement, :beneficiary_payments, :security_deposits, :general_invoices, :rental_invoices

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
    case 
    when payment_agreement.general_invoices.present?
      self.general_invoices = payment_agreement.general_invoices
    when payment_agreement.rental_invoices.present?
      self.rental_invoices = payment_agreement.rental_invoices
    when payment_agreement.beneficiary_payments.present?
      self.beneficiary_payments = payment_agreement.beneficiary_payments
    when payment_agreement.security_deposits.present?
      self.security_deposits = payment_agreement.security_deposits
    end
  end

  def success
    params[:beneficiary_payments] = self.beneficiary_payments
    params[:security_deposits] = self.security_deposits
    params[:general_invoices] = self.general_invoices
    params[:rental_invoices] = self.rental_invoices
    PaymentAgreements::UpcomingInvoices::UpcomingInvoicesPresenter.new(user, params, messages)    
  end

  class PaymentAgreements::UpcomingInvoices::UpcomingInvoicesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoices, :beneficiary_payments, :security_deposits, :general_invoices, :rental_invoices

    def init
      self.beneficiary_payments = params[:beneficiary_payments]
      self.security_deposits = params[:security_deposits]
      self.general_invoices = params[:general_invoices]
      self.rental_invoices = params[:rental_invoices]
    end
  end

end