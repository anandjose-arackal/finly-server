class BankTransfer::InwardInvoices::Base < BankTransfer::Base

  attr_accessor :inward_invoice

  class BankTransfer::InwardInvoices::Show::InvoicePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoice, :budgets

    def init
      self.invoice = params[:inward_invoice]
      # op = BudgetsCalculator::RelevantBudgets.(user, object: self.invoice)
      # if op.success?
      #   self.budgets = op.budget_data
      # end
    end
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def invoice_attributes
    params.require(:invoice).permit(:note, :tax, :gst_type_id, :tds, :tds_type_id, :category_id, :cost_center_id, :tds_slab_id, :payment_term_id,
                                    :department_id, :sub_department_id, :policy_id, :billing_address, :shipping_address,
                                     :tax_type_id, :discount, :date, :discount_type_id, :due_date, :roundoff_amount, :location_id, :delivery_location_id,
                                     :invoice_number, :inclusive_of_taxes, :advance, :advance_type_id, :receiving_account_id, :vendor_id, :advance_amount_required,
                                     original_amount_attributes: [:value, :currency_id],
                                     freight_amount_attributes: [:value, :currency_id],
                                     advance_amount_attributes: [:value, :currency_id],
                                     po_adjusted_advance_attributes: [:value, :currency_id],
                                     attachments: [],
                                     invoice_attachments_attributes: [:attached_file, :description, :remove_file],
                                     invoice_items_attributes: [:quantity, :rate, :tax, :tax_rate_id, :discount, :category_id, :description, :id, :remove_line_item, :hsn_sac, :comment, :_destroy,
                                     :inventory_line_item_id],
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

  def validate_custom_fields_invoice
    set_fields = set_custom_fields_invoice self.inward_invoice, self.custom_fields, false
    unless set_fields.success?
      add_message :error, set_fields.messages[:error]
      return
    end
    valid = CustomField::Validate.(self.inward_invoice)
    unless valid.success?
      add_message :error, valid.messages[:error]
      return
    end
  end

  def set_custom_fields_invoice(invoice, data, save)
    custom_fields = {custom_fields: data}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(invoice, FieldParentType.id_for(:invoice), custom_fields)
  end

end