class User::Cards::AllCards < User::Cards::Base

  attr_accessor :cards, :selected_user, :card_program_id

  class User::Cards::AllCardsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :cards

    def init
      self.cards = params[:cards]
    end
  end

  def pre_validate
    if user.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    id = params[:user_id] || params[:id]
    self.selected_user = current_company.users.find_by(id: id)
    if selected_user.blank?
      self.selected_user = user
    end
    card_type = params[:card_type]
    case card_type
      when "expense"
        self.card_program_id = CardProgram.id_for(:expense)
      when "reimbursement"
        self.card_program_id = CardProgram.id_for(:reimbursement)
      else
        self.card_program_id = CardProgram.id_for(:expense)
    end
  end

  def process
    self.cards = Card.unscoped.with_card_program(self.card_program_id).with_user_id(self.selected_user.id)
  end

  def success
    params[:cards] = self.cards
    User::Cards::AllCardsPresenter.new(user, params, messages)
  end
end