class Categories::Create < Categories::Base
  attr_accessor :category

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    super
    # here we need all categories, not just inactive ones
    self.category = user.company.categories.with_name(category_params[:name]).first rescue nil
  end

  def process
    if self.category.present? && self.category.root?
      self.category.assign_attributes(category_params)
      self.category.update(active: true)
    else
      self.category = user.company.categories.build(category_params)
    end
    unless category.save
      messages[:error] = category.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, "Category added"
  end

  private

  def category_params
    params.require(:category).permit(:name,:gl_code,  :expense_management, :vendor_payments, :outward_invoices, :inward_invoice_line_items, :outward_invoice_line_items, :parent_id)
  end
end