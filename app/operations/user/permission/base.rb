class User::Permission::Base < User::Base

  attr_accessor :permission, :selected_user

  def init
    self.selected_user = user
    self.permission = selected_user&.permission
  end

  def validate
    unless self.selected_user && self.permission
      add_message :error, "User not found"
    end
  end

  def permission_params
    params.require(:permission).permit(:create_beneficiaries,:edit_terms_within_po)
  end
end