class Users::Deactivate < Users::Base

  attr_accessor :selected_user

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.company = user.company
    id = params[:id] || params[:user_id]
    self.selected_user = self.company.users.find_by(id: id)
  end

  def validate
    if self.selected_user.blank?
      add_message :error, "User not found. Try again"
    end
  end

  def process
    self.selected_user.update(active: false)
  end

  def post_process
    add_message :success, "User successfully deactivated"
  end
end