class Invoicing::Invoice::Base < BaseOperation

  class Invoicing::Invoice::Base::InvoicePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoice

    def init
      self.invoice = params[:invoice]
    end

  end

  def invoice_params
    params.require(:invoice).permit(:tax, :gst_type_id, :tds, :tds_type_id, :category_id,
                                     :tax_type_id, :discount, :date, :discount_type_id, :due_date,
                                     :invoice_number, :inclusive_of_taxes,
                                     original_amount_attributes: [:value, :currency_id],
                                     freight_amount_attributes: [:value, :currency_id],
                                     invoice_attachments_attributes: [:attached_file, :description])
  end

end