class Streamsets::Transactions::Invoices < BaseOperation
	attr_accessor :input_data
  def pre_validate

  end

  def init
  	result = BankTransfer::InwardInvoices::Index.(user, params)

    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    
    invoices = result.invoices
    self.input_data = InvoiceLineItem.where(parent_type: 'Invoice', parent_id: invoices.pluck(:id)).includes({purchase_order_item: :purchase_order},:category,:department,:tax_rate,:cost_center, {inventory_line_item: [:item_expense_type, :supply_item_type, :product_type, :category]}, {amount: :currency}, {tax_amount: :currency},:discount_amount,parent: [:invoice_type,:vendor,{delivery_location: :state},:invoice_status, :gst_type,  {location: :state},:receiving_account, :tds_slab,:advance_amount,:balance_due,:discount_amount,{created_by: :profile},{vendor_location: :state}, {gstin_location: :state}, {dlrms: [:reviewer,:taken_control_by, :forwarded_to]},{custom_fields: [:value, :field_configuration]},{tds_amount: :currency},:amount,{procurement: [{purchase_order: :advance_amount}]}])
  end

  def success
  	params[:invoice_line_items] = self.input_data
  	Streamsets::Transactions::InvoicesPresenter.new(user, params, messages)
  end 

  class Streamsets::Transactions::InvoicesPresenter < BaseOperation::BasePresenter::SuccessPresenter
  	attr_accessor :invoice_line_items, :paginated_invoice_line_items

  	def init
  		self.invoice_line_items = params[:invoice_line_items]
  		page = params[:page] || 1
  		per_page = params[:per_page] || 500
  		self.paginated_invoice_line_items = self.invoice_line_items.order(created_at: :desc).paginate(page: page, per_page: per_page)
  	end

  end

end