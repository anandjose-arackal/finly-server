class Admin::Users::Team::Mappings::Destroy < User::Team::Mappings::Destroy

  def pre_validate
    super()
    if params[:mapping_id].blank?
      add_message :error, "Nothing to remove"
    end
  end

  def pre_authorize
    # just to override the whole heriarchical seaching in the parent class

  end

  def init
    id = params[:id] || params[:user_id]
    self.updating_user = User.find_by(id: id)
    self.updating_mapping = updating_user.team_mapping.with_id(params[:mapping_id]).first rescue nil
  end

  def post_process
    add_message :success, "Mapping destroyed"
  end

end