# operation to assign a particular card to a particular person by the company admin
class Card::Assign < Card::Base

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
    self.selected_user = user.company.users.find_by(id: params[:user_id])
    self.card = user.company.cards&.unassigned&.find_by(id: params[:card_id])
    self.card_program = CardProgram.find_by(id: params[:card_program_id])
  end

  def validate
    if card.blank?
      add_message :error, "Card not found"
      return
    end

    if selected_user.blank?
      add_message :error, "User not found"
      return
    end


  end

  def process
    unless card.update(user_id: selected_user.id)
      add_message :error, card.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Card assigned"
  end
end