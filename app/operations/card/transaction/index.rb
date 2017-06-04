# Retrieves transactions based on user or card
class Card::Transaction::Index < BaseOperation

  attr_accessor :transactions, :selected_user, :selected_card

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, 'Invalid parameters, try again'
      return
    end
    if params[:user].blank? and params[:user_id].blank? and params[:card].blank? and params[:card_id].blank? and params[:id].blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.selected_user = params[:user]
    self.selected_card = params[:card]

    if selected_user.blank? and selected_card.blank?
      if params[:user_id].present?
        self.selected_user = User::Index.(user, params).team.find_by(id: params[:user_id]) rescue nil
      elsif params[:card_id].present? or params[:id].present?
        self.selected_card = Card::Index.(user, params).cards.find_by(id: (params[:card_id] or params[:id])) rescue nil
      end
    end
    # self.transactions = selected_user.card_transactions
    # unless personal_view? or selected_user == user
    #
    # end
  end

  def authorize

  end

  def validate
    if self.selected_user.blank? and self.selected_card.blank?
      add_message :error, 'Card not found'
      return
    end
  end

  def process
    if selected_user
      self.transactions = selected_user.card_transactions
    elsif selected_card
      self.transactions = selected_card.transactions
    end
  end

  def success
    params[:transactions] = transactions
    Card::Transaction::PaymentsPresenter.new(user, params, messages)
  end

  class Card::Transaction::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    include HasScope

    has_scope :filter_refunds

    attr_accessor :transactions

    def init
      self.transactions = params[:transactions]
      self.transactions = apply_scopes(transactions, params)
    end

  end
end