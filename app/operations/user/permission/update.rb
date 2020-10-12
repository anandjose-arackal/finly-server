class User::Permission::Update < User::Permission::Base

  attr_accessor :selected_user, :permission

  def init
    id = params[:id] || params[:selected_user_id]
    self.selected_user = BankTransfer::Users::Index.(user, params).users.find_by(id: id) rescue nil
    self.permission = selected_user&.permission
  end

  def process
    unless self.permission.update(permission_params)
      add_message :error, self.permission.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Permissions updated"
  end
end