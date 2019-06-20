class PaymentAgreements::InvoiceHistory < PaymentAgreements::Base
  attr_accessor :invoices, :payment_agreement

  def init
    id = params[:id] || params[:payment_agreement_id]
    self.payment_agreement = user.company.payment_agreements.find_by_id id
  end

  def validate
    if payment_agreement.blank?
      add_message :error, 'Agreement not found'
    end

    # unless payment_agreement.approved? || payment_agreement.approved?
    #   add_message :error, 'Payment agreement should be approved for raising invoices'
    # end
  end

  def process
    case 
    when payment_agreement.general_invoices.present?
      self.invoices = payment_agreement.general_invoices
    when payment_agreement.rental_invoices.present?
      self.invoices = payment_agreement.rental_invoices
    when payment_agreement.beneficiary_payments.present?
      self.invoices = payment_agreement.beneficiary_payments
    when payment_agreement.security_deposits.present?
      self.invoices = payment_agreement.security_deposits
    end
  end

  def success
    params[:invoices] = self.invoices
    PaymentAgreements::InvoiceHistory::UpcomingInvoicesPresenter.new(user, params, messages)    
  end

  class PaymentAgreements::InvoiceHistory::UpcomingInvoicesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoices

    def init
      # self.invoices = params[:invoices]
      self.invoices = user.company.inward_invoices
    end
  end

end