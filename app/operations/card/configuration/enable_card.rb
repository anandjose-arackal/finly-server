# enables a card belonging to a particular user. Enabling can be done by user or manager.
# If disabled by user - user / manager can re-enable, if disabled by manager, only they can re-enable

# PARAMETERS:
# card_id : id of the card that needs to be enabled
# employee_id : optional, if a manager is trying to enable the card of employee under him
# self : set to true if user is enabling the card himself

class Card::Configuration::EnableCard < Card::Base

  attr_accessor :employee

  def authorized_user_types
    [:employee, :manager, :admin]
  end

  def pre_validate
    if self.user.blank?
      messages[:error] << "User not found!"
    end
    if params[:card_id].blank?
      messages[:error] << "Card not found!"
    end
    if !params[:self] and params[:employee_id].blank?
      messages[:error] << "Employee not found!"
    end
  end

  def init
    self.card = user.company.cards.find_by_id(params[:card_id])
    self.employee = user.company.users.find_by_id(params[:employee_id])
  end

  def validate
    # i.e. it's manager view
    if employee.nil? and params[:self].nil?
      messages[:error] << "Employee does not exist."
    end
    # i.e. if the card is already deactivated
    if card.active
      messages[:error] << "Card is already active."
    end
  end

  def authorize
    if user.admin? and !!params[:self]
      unless employee.company_id == user.company_id
        messages[:error] << "You are not an admin for this employee."
      end
      # if manager view, user must be employee's manager
    elsif user.manager? and !params[:self]
      unless User::Team::Index.call(user, 3, indirect_associations: true).include?(employee) and card.disabled_by_role_id >= 3
        messages[:error] << "You are not authorized to enable this card."
      end
      # if employee, he must own the card and should have been disabled by him
    elsif user.employee? and params[:self]
      unless card.user_id == user.id and card.disabled_by_role_id >= 4
        messages[:error] << "You are not authorized to enable this card."
      end
    end
  end

  def process
    if card.update_attributes(active: true, disabled_by_role_id: nil)
      success
    else
      messages[:error] = card.errors.full_messages
    end
  end

  def post_process
    # send mail to user informing about reactivation
  end

  def success
    card
  end
end