class BankTransfer::InwardInvoices::Base < BankTransfer::Base



  class BankTransfer::InwardInvoices::Show::InvoicePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoice

    def init
      self.invoice = params[:inward_invoice]
    end

  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def invoice_attributes
    params.require(:invoice).permit(:note, :tax, :gst_type_id, :tds, :tds_type_id, :category_id, :cost_center_id, :tds_slab_id,
                                     :tax_type_id, :discount, :date, :discount_type_id, :due_date, :roundoff_amount,
                                     :invoice_number, :inclusive_of_taxes, :advance, :advance_type_id, :receiving_account_id, :vendor_id,
                                     original_amount_attributes: [:value, :currency_id],
                                     freight_amount_attributes: [:value, :currency_id],
                                     advance_amount_attributes: [:value, :currency_id],
                                     invoice_attachments_attributes: [:attached_file, :description, :remove_file],
                                     invoice_items_attributes: [:quantity, :rate, :tax, :discount, :category_id, :description, :id, :remove_line_item, :hsn_sac],
                                     custom_fields: [])
  end

  def calculate_tax_and_discounts(invoice, invoice_params)
    if invoice.blank?
      return
    end
    if invoice.invoice_items.present?
      # if there are no invoice items, use the invoice library to calculate the amounts
      InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts(invoice_params, nil, invoice)
    else
      # if there are, in fact, invoice items, use the invoice items library
      InvoiceCalculationUtils.new.calculate_tax_and_discounts(invoice_params, nil, invoice)
    end
    return
  end

  def recalculate_totals(invoice, invoice_params)
    if invoice.invoice_items.present?
      InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts(invoice_params, nil, invoice)
    else
      # if there are, in fact, invoice items, use the invoice items library
      InvoiceCalculationUtils.new.calculate_tax_and_discounts(invoice_params, nil, invoice)
    end
    invoice.save
  end

end