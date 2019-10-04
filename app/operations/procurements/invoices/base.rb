class Procurements::Invoices::Base < BaseOperation
  attr_accessor :workflow_output


  class Procurements::Invoices::InwardInvoicePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoice

    def init
      self.invoice = params[:inward_invoice]
    end

  end

  private
  def validate_agreement_limit
    if self.invoice.agreement_item.present? && 
      payment_agreement = invoice.agreement_item.payment_agreement
      if invoice.agreement_item.total_invoice_amount&.value.present? && invoice.agreement_item.billing_type.variable_periodic?
        available_limit = get_available_limit(payment_agreement) 
        
        if available_limit < invoice&.balance_due&.value
          add_message :error, "Balance due cannot exceed available agreement limit of Rs. #{available_limit}"
          return
        end
      end
    end
  end

  def update_agreement_available_limit
    if self.invoice.agreement_item.present?
      payment_agreement = self.invoice.agreement_item.payment_agreement
      invoiced_amount_sum = get_invoice_amount_sum(payment_agreement)
      available_limit = self.invoice.agreement_item.total_invoice_amount&.value - invoiced_amount_sum
      self.invoice.agreement_item.available_invoice_amount.update(value: available_limit, currency_id: 1)
      return
    end
  end

  # For invoices created from variable periodic agreement based payments
  # Its the sum for ABP actual invoices
  def get_invoice_amount_sum(payment_agreement)
    payment_agreement.agreement_invoices.where(agreement_item_id: self.invoice.agreement_item_id).where.not(status: [InwardInvoiceStatus.id_for(:open), InwardInvoiceStatus.id_for(:retracted), InwardInvoiceStatus.id_for(:rejected)]).collect{|i| i.balance_due.value}.sum
  end

  # Get limit for this invoice
  def get_available_limit(payment_agreement)
    invoice.agreement_item.total_invoice_amount&.value - payment_agreement.agreement_invoices.where(agreement_item_id: self.invoice.agreement_item_id).where.not(id: self.invoice.id, status: [InwardInvoiceStatus.id_for(:open), InwardInvoiceStatus.id_for(:retracted), InwardInvoiceStatus.id_for(:rejected)]).collect{|i| i.balance_due.value}.sum
  end
end