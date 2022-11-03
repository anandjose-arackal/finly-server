class Procurements::Invoices::FetchReviewalChain < Procurements::Invoices::Base
  attr_accessor :invoice

  def init
    invoice_id = params[:id] || params[:invoice_id] || params[:inward_invoice_id]
    self.invoice = user.company.inward_invoices.find_by id: invoice_id
  end

  def validate
    return if record_not_present
  end

  def validate_presence
    if invoice.blank?
      add_message :error, 'Record not found'
      return false
    end
    true
  end

  def record_not_present
    !validate_presence
  end

  def success
    params[:invoice] = self.invoice
    Procurements::Invoices::FetchReviewalChain::ShowPresenter.new(user, params, messages)
  end

  class Procurements::Invoices::FetchReviewalChain::ShowPresenter
    def init
      self.invoice = params[:invoice]
      params[:reviewal_document] = self.invoice
      params[:provider_name] = get_invoice_provider_name
      # params[:policy_id] is assumed to be present

      op = ::ReviewalManager::ReviewalChain.(user, params)
      self.chain = op.chain
    end


    def get_invoice_provider_name
      if self.invoice.procurement.purchase_order.present?
        return 'PoInvoiceProvider'
      elsif self.invoice.payment_agreement_id.present?
        return 'AgreementInvoiceProvider'
      else
        return 'NonPoInvoiceProvider'
      end
    end
  end


end