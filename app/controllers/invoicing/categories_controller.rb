class Invoicing::CategoriesController < BaseControllers::WebBase

  before_action -> { finly_authorize! :web }

  def invoice_categories
    @result = Categories::Invoices::Index.(current_user, params)
    respond
  end

  def invoice_items_categories
    @result = Categories::InvoiceItems::Index.(current_user, params)
    respond
  end

  def outward_invoice_categories
    @result = Categories::OutwardInvoices::Index.(current_user, params)
    respond
  end

end
