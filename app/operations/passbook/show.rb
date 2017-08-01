class Passbook::Show < BaseOperation
  attr_accessor :payments, :card_transactions, :account_types

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    # company_credits, cash_on_hand, finly_money, :expense_card, :reimbursement_card
    self.account_types = params[:account_types]
    users = User::Team::Index.(user, params)
    accounts = []
    self.account_types.each do |type|
      if type == 'company_credits'
        # todo update to company_credits after yes bank is implemented
        accounts << user.company
      else
        users.each do |user|

        end
      end
    end
  end

  def validate

  end

  def process

  end

end