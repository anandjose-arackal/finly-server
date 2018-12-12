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
    self.transactions = nil

    if selected_card.blank?
      if params[:card_id].present? or params[:id].present?
        self.selected_card = Card::Show.(user, params).card rescue nil
        # self.selected_card = Card::Index.(user, params).cards.find_by(id: (params[:card_id] or params[:id])) rescue nil
      end
    end

    # i.e. if the selected card is still blank, it's from the disburse view
    if selected_card.blank?
      if personal_view?
        self.selected_user = user
      elsif params[:user_ids].present?
        if params[:user_ids].is_a?(String)
          user_ids = params[:user_ids].split(",")
        else
          user_ids = params[:user_ids]
        end
        if user_ids.present?
          self.selected_cards = Card.with_user(user_ids).manager_viewable_transactions.pluck(:id) rescue nil
        end
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
    if selected_card.present?
      self.transactions = selected_card.transactions
    elsif selected_cards.present?
      self.transactions = CardTransaction.with_card(selected_cards)
    elsif selected_user.present?
      self.transactions = selected_user.card_transactions
    else
      self.transactions = CardTransaction.with_id([])
    end
  end

  def success
    params[:transactions] = transactions
    Card::Transaction::PaymentsPresenter.new(user, params, messages)
  end

  class Card::Transaction::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :transactions, :count, :paginated_transactions
    include HasScope

    has_scope :filter_refunds
    has_scope :filter_atm_withdrawals
    has_scope :filter_date, using: [:from, :to], type: :hash
    has_scope :filter_user_id


    def init
      self.transactions = params[:transactions]
      page = params[:page] || 1
      per_page = params[:per_page] || 30
      self.count = self.transactions.count
      self.paginated_transactions = apply_scopes(transactions, params).paginate(page: page, per_page: per_page)
    end

  end
end