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
  end

  def validate
    if card.blank?
      add_message :error, "Card not found"
      return
    end

    if selected_user.blank?
      add_message :error, "User not found"
    end
  end
end