class Categories::Update < Categories::Base

  attr_accessor :category, :category_parameters

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def init
    super
    id = params[:id] || params[:category_id]
    self.category = user.company.categories.find_by(id: id)
    self.category_parameters = category_params
  end

  def validate
    parent = user.company.categories.find_by(id: category_parameters[:parent_id])
    if parent.present?
      if parent.id == self.category.id
        add_message :error, "#{self.category.name} cannot be a sub-category of itself"
        return
      end

      # checking if the current category is already a parent
      if self.category.children.present?
        add_message :error, "This category already has sub-categories associated with it"
        return
      end
    end
  end

  def pre_process
    [:expense_management, :vendor_payments, :outward_invoices, :inward_invoice_line_items, :outward_invoice_line_items,:gst_applicable,:tds_applicable].each do |app|
      if self.category_parameters&.dig(app).blank?
        self.category_parameters[app] = false
      end
    end
  end

  def process
    if category.update(category_parameters)
      # i.e. if there is a parent and the child's subscriptions have been updated
      # the parent's subscription should also be updated accordingly
      if self.category.parent.present?
        [:expense_management, :vendor_payments, :outward_invoices, :inward_invoice_line_items, :outward_invoice_line_items,:gst_applicable,:tds_applicable].each do |app|
          unless self.category.parent.send(app)
            self.category.parent.update(app => self.category.send(app))
          end
        end
      end

      if self.category.children.present?
        [:gst_applicable,:tds_applicable].each do |app|
          unless self.category.send(app)
            self.category.children.each do |child_category|
             child_category.update(app => self.category.send(app))
            end
          end
        end
      end
    else
      messages[:error] = category.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, "Category updated"
  end

  private

  def category_params
    params.require(:category).permit(:name, :gl_code, :gst_applicable, :tds_applicable,
                                     :expense_management, :vendor_payments, :outward_invoices, :inward_invoice_line_items, :outward_invoice_line_items, :parent_id)
  end

end