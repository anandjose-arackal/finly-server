# disables a card that a particular user is using. Disabling can be done by user or manager.
# If disabled by user - user / manager can re-enable, if disabled by manager, only they can reactivate

# PARAMETERS:
# card_id : id of the card that needs to be disabled
# employee_id : optional, if a manager is trying to disable the card of user under him
# self : set to true if user is disabling the card himself

class Card::Configuration::DisableCard < Card::Base

  attr_accessor :employee

  def authorized_user_types
    [:employee, :manager, :admin]
  end

  def pre_validate
    if self.user.blank?
      errors << "User not found!"
    end
    if params[:card_id].blank?
      errors << "Card not found!"
    end
    if params[:self] and params[:employee_id].blank?
      errors << "Employee not found!"
    end
  end

  def init
    self.card = user.company.cards.find_by_id(params[:card_id])
    self.employee = user.company.users.find_by_id(params[:employee_id])
  end
end