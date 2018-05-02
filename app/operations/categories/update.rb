class Categories::Update < Categories::Base

  attr_accessor :category

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    super
    id = params[:id] || params[:category_id]
    self.category = user.company.categories.active.find_by(id: id)
  end

  def process
    unless category.update(category_params)
      messages[:error] = category.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, "Category updated"
  end

  private

  def category_params
    params.require(:category).permit(:name, :expense_management, :vendor_payments, :outward_invoices, :inward_invoice_line_items, :outward_invoice_line_items, :parent_id)
  end

end