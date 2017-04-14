class Admin::Users::Team::Set < User::Team::Mappings::Set

  def pre_validate
    super()
  end

  def authorized_user_types

  end


  def init
    id = (params[:id] || params[:user_id])
    self.updating_user = User.find_by(id: id)
    return if self.updating_user.blank?
    self.mappings = updating_user.team_mapping
    self.updating_policy_config = params[:user_policy_config]
    self.updating_mapping = params[:user_manager_mapping]
    load_updating_records
    load_updating_policy_config
  end

  def post_process
    add_message :success, "User mapping updated!"
  end
end