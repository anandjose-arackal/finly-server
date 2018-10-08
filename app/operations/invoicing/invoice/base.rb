class Invoicing::Invoice::Base < BaseOperation

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  class Invoicing::Invoice::Base::InvoicePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoice, :invoice_number

    def init
      self.invoice = params[:invoice]
      self.invoice_number = params[:invoice_number]
    end

  end

  def invoice_params
    params.require(:invoice).permit(:tax, :gst_type_id, :tds, :tds_slab_id, :category_id,
                                     :tax_type_id, :discount, :date, :discount_type_id, :due_date, :payment_term_id,
                                     :invoice_number, :inclusive_of_taxes, :outward_invoice_type_id,
                                     original_amount_attributes: [:value, :currency_id],
                                     advance_amount_attributes: [:value, :currency_id],
                                     freight_amount_attributes: [:value, :currency_id],
                                     invoice_attachments_attributes: [:attached_file, :description],
                                     invoice_items_attributes: [:id, :remove_line_item, :description, :category_id, :hsn_sac, :quantity, :rate, :discount, :tax])
  end

end