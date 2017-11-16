class User::Permission::Update < User::Permission::Base

  attr_accessor :selected_user, :permission

  def process
    unless self.permission.update(permission_params)
      add_message :error, self.permission.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Permissions updated"
  end
end