# Retrieves transactions based on user or card
class Card::Transaction::Index < BaseOperation

  attr_accessor :transactions, :selected_user, :selected_card, :selected_cards

  def pre_validate
    if user.blank?
      add_message :error, 'Invalid parameters, try again'
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
    
    if selected_card.blank? and selected_user.blank?
      if personal_view?
        self.selected_user = user
      else
        users = User::Index.(user, params)
        unless users.success?
          add_message :error, users.messages[:error]
          return
        end
        selected_user_ids = users.team.pluck(:id) rescue nil
        if selected_user_ids.present?
          self.selected_cards = Card.with_user(selected_user_ids).manager_viewable_transactions.pluck(:id) rescue nil
        end
      end
    end
  end

  def authorize

  end

  def validate
    if self.selected_user.nil? and self.selected_card.nil? and self.selected_cards.nil?
      add_message :error, 'Card not found'
      return
    end
  end

  def process
    if selected_user
      self.transactions = selected_user.card_transactions
    elsif selected_card
      self.transactions = selected_card.transactions
    elsif selected_cards
      self.transactions = CardTransaction.with_card(selected_cards)
    end
  end

  def success
    params[:transactions] = transactions
    Card::Transaction::PaymentsPresenter.new(user, params, messages)
  end

  class Card::Transaction::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    include HasScope

    has_scope :filter_refunds
    has_scope :filter_atm_withdrawals

    attr_accessor :transactions

    def init
      self.transactions = params[:transactions]
      self.transactions = apply_scopes(transactions, params)
    end

  end
end