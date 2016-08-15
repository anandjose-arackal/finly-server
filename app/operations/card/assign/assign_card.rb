# assigns a card to given user, from the pool of available cards in the company

# PARAMETERS :
# employee_id : the employee on whom the operation (assign or unassign) is to be performed
# card_id : in case of unassign
# unassign : set to true if it's an unassign operation

class Card::Assign::AssignCard < Card::Base
  attr_accessor :unassigned_card, :employee

  def authorized_user_types
    [:manager, :admin]
  end

  def pre_validate
    if user.blank?
      errors << "User not found!"
    end
    if params[:employee_id].blank?
      errors << "No user to assign card to!"
    end
    # for unassigning cases
    if params[:unassign] and params[:card_id].blank?
      errors << "Cannot unassign card without card id."
    end
  end

  def init
    # loading the card and user who will now be married to each other
    self.unassigned_card = user.company.cards.unassigned.first
    self.employee = user.company.users.find_by_id(params[:employee_id])
    # for unassigning a card
    self.card = user.company.cards.find_by_id(params[:card_id]) if params[:card_id]
  end

  def validate
    unless employee
      errors << "Employee does not exist!"
    end
    if params[:unassign]
      # checking that card exists and belongs to the specified employee
      unless card and card.user.id == employee.id
        errors << "Card not found. Pliss try again."
      end
    else
      # if assigning a card, checking if there are available cards to assign
      unless unassigned_card
        errors << "There are no more available cards to allocate. Please ask your administrator to request more cards."
      end
    end
  end

  def authorize
    if user.manager?
      unless User::Team::Show.call(user, 3, indirect_associations: true).include?(employee)
        errors << "You are not a manager for this user."
      end
    elsif user.admin?
      unless employee.company_id == user.company_id
        errors << "You are not an admin for this employee."
      end
    end
  end

  def process
    if params[:unassign]
      if card.update_attributes(user_id: nil)
        self.response = success
      else
        errors << "Couldn't unassign card. Please try again."
      end
    else
      if unassigned_card.update_attributes(user_id: employee.id)
        self.response = unassigned_card
      else
        errors << "Couldn't assign card. Please try again."
      end
    end
  end

  def post_process
    # mail to user informing them of their new card allocation
  end

end