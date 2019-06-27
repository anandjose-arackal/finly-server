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
  end

  def process
    self.invoices = payment_agreement.invoices.with_status_id(BankPaymentRequestStatus.id_for(:invoice_created))
  end

  def success
    params[:invoices] = self.invoices
    PaymentAgreements::InvoiceHistory::UpcomingInvoicesPresenter.new(user, params, messages)
  end

  class PaymentAgreements::InvoiceHistory::UpcomingInvoicesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoices

    def init
      self.invoices = params[:invoices]
    end
  end

end