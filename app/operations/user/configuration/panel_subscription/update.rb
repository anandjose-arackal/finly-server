class User::Configuration::PanelSubscription::Update < BaseOperation

  attr_accessor :selected_user

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    id = params[:id] || params[:user_id]
    self.selected_user = user.company.users.find_by(id: id)
  end

  def validate

  end

  def process

  end

end