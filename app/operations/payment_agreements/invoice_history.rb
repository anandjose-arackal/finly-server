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
    self.invoices = payment_agreement.recurring_invoices
  end

  def success
    params[:invoices] = self.invoices
    PaymentAgreements::InvoiceHistory::UpcomingInvoicesPresenter.new(user, params, messages)
  end

  class PaymentAgreements::InvoiceHistory::UpcomingInvoicesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoices, :paginated_invoices

    def init
      page = params[:page] || 1
      per_page = params[:per_page] || 30

      self.invoices = params[:invoices]
      self.paginated_invoices = self.invoices.paginate(page: page, per_page: per_page) rescue ::Invoice.none
    end
  end

end