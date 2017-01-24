class User::CardRestrictions::Destroy < User::Base

  attr_accessor :selected_user, :card_limit

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      add_message :error, "Invalid input, please try again"
    end
  end

  def init
    self.card_limit = CardLimit.find_by(id: params[:limit_id])
    self.selected_user = user.company.users.find_by(id: params[:id])
  end

  def validate
    unless card_limit
      add_message :error, "Invalid parameters. Please try again"
      return
    end
  end


end