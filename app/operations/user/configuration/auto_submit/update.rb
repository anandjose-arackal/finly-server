class User::Configuration::AutoSubmit::Update < BaseOperation
  attr_accessor :selected_user, :update_param

  def authorized_user_types
    :company_admin
  end

  def pre_validate
    if params.blank? or user.blank? or params[:user].blank? or (params[:user][:id].blank? and params[:user][:user_id].blank?)
      add_message :error, 'User not found'
    end
  end

  def init
    self.update_param = update_params
    id = (params[:user][:id] or params[:user][:user_id])
    self.selected_user = User::Team::Index.(user, params).with_id(id).first rescue nil
  end

  def authorize
    raise_unauthorized_exception if self.selected_user.blank?
  end

  def validate
    if update_param.blank?
      add_message :error, 'Error updating configuration'
      return
    end
    if update_param.blank?
      add_message :error, 'Nothing to update'
    end
  end

  def process
    auto_submit_config = self.selected_user.auto_submit_config
    unless auto_submit_config.update_attributes(update_param)
      add_message :error, auto_submit_config.errors.full_messages
    end
  end

  protected
  def update_params
    self.params.require(:user).permit(:enabled, :period_id, :default_note, :default_policy_id)
  end

end