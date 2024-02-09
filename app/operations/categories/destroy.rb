# with unified categories, this will now only remove the category from the respective application that
class Categories::Destroy < Categories::Base
  attr_accessor :category

  def pre_validate
    unless params[:id].present? or params[:category_id].present?
      messages[:error] << 'Category ID not found'
    end
  end
  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def init
    super
    id = (params[:id] or params[:category_id])
    self.category = self.user.company.categories.with_id(id).first
  end

  def validate
    unless self.category.present?
      messages[:error] << 'Category not found'
      return false
    end
    if category.name == "Other"
      messages[:error] << "Cannot remove 'Other' category"
      return false
    end

    if self.category.children.active.present?
      add_message :error, "This category has sub-categories associated with it. Delete all sub-categories and try again"
      return
    end
  end

  def process
    unless self.category.update_attributes(active: false)
      messages[:error] = self.category.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Category destroyed'
  end

end