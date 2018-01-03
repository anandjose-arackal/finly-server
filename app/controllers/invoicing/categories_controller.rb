class Invoicing::CategoriesController < ApplicationController

  before_action -> { finly_authorize! :web }

  def invoice_categories
    @result = Category::Invoice::Index.(current_user, params)
    respond
  end

  def invoice_items_categories
    @result = Category::InvoiceItems::Index.(current_user, params)
    respond
  end

end