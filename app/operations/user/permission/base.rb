class User::Permission::Base < User::Base

  attr_accessor :permission, :selected_user

  def init
    id = params[:id] || params[:selected_user_id]
    self.selected_user = User::Team.(user, params).team.find_by(id: id) rescue nil
    self.permission = selected_user&.permission
  end

  def validate
    unless self.selected_user && self.permission
      add_message :error, "User not found"
    end
  end

  def permission_params
    params.require(:permission).permit(:create_beneficiaries)
  end
end