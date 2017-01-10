class User::Configuration::EnforcePolicy::Base < BaseOperation

  attr_accessor :selected_user, :enforce_config

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate

  end

  def init
    id = params[:id] || params[:user_id]
    self.selected_user = user.company.users.find_by(id: id)
    self.enforce_config = selected_user.enforce_policy
  end

end
