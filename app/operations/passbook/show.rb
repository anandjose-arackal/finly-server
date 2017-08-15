class Passbook::Show < BaseOperation
  attr_accessor :payments, :card_transactions, :account_types

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    # company_credits, cash_on_hand, finly_money, :expense_card, :reimbursement_card, :others
    self.account_types = params[:account_types]
    users = User::Team::Index.(user, params)
    accounts = []
    self.account_types.each do |type|
      if type == 'company_credits'
        accounts << user.company.itz_cash_company_account
      else
        users.each do |user|
          case type.to_sym
            when :finly_money
              accounts << user.wallet
            when :expense_card
              accounts << user.cards.expense_cards
            when :reimbursement_card
              accounts << user.cards.reimbursement_cards
            when :cash_on_hand
              accounts << user.cash_on_hand
            when :others
              # todo others
          end
        end
      end
    end
  end

  def validate

  end

  def process

  end

end