# disables a card that a particular user is using. Disabling can be done by user or manager.
# If disabled by user - user / manager can re-enable, if disabled by manager, only they can reactivate

# PARAMETERS:
# card_id : id of the card that needs to be disabled
# employee_id : optional, if a manager is trying to disable the card of user under him
# self : set to true if user is disabling the card himself

class Card::Configuration::DisableCard < Card::Base

  attr_accessor :employee, :response

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
    if !params[:self] and params[:employee_id].blank?
      errors << "Employee not found!"
    end
  end

  def init
    self.card = user.company.cards.find_by_id(params[:card_id])
    self.employee = user.company.users.find_by_id(params[:employee_id])
  end

  def validate
    # i.e. it's manager view
    if employee.nil? and params[:self].nil?
      errors << "Employee does not exist."
    end
    # i.e. if the card is already deactivated
    unless card.active
      errors << "Card is already disabled."
    end
  end

  def authorize
    if user.admin? and !!params[:self]
      unless employee.company_id == user.company_id
        errors << "You are not an admin for this employee."
      end
    # if manager view, user must be employee's manager
    elsif user.manager? and !params[:self]
      unless User::Team::Show.call(user, 3, indirect_associations: true).include?(employee)
        errors << "You are not a manager for this employee."
      end
    elsif user.employee? and params[:self]
      unless card.user_id == user.id
        errors << "You do not own this card."
      end
    end
  end

  def process
    if user.admin?
      unless card.update_attributes(active: false, disabled_by_role_id: UserRole.admin_id)
        errors << card.errors.full_messages
      end
    # if manager view, user must be employee's manager
    elsif user.manager?
      unless card.update_attributes(active: false, disabled_by_role_id: UserRole.manager_id)
        errors << card.errors.full_messages
      end
    elsif user.employee? and params[:self]
      unless card.update_attributes(active: false, disabled_by_role_id: UserRole.employee_id)
        errors << card.errors.full_messages
      end
    end
    success
  end

  def post_process
    # send mail to user indicating deactivation of card
  end

  def retrieve
    if is_success?
      return card
    else
      return false
    end
  end

end