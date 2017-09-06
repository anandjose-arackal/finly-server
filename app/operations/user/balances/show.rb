class User::Balances::Show < User::Base

  attr_accessor :balances, :current_app, :selected_user

  def init
    self.current_app = RequestStore.store[:current_app].to_s
    self.balance = {}
    if admin_panel?
      id = params[:id] || params[:user_id]
      self.selected_user = User.find_by(id: id)
    else
      self.selected_user = user
    end
  end

  def validate

  end

  def process
    case current_app
      when 'em'
        # Adding expense management balances in this section if it's enabled for that user
        if selected_user.company.expense_management_enabled? && selected_user.expense_management_enabled?
          if selected_user.admin?
            self.balances[:card_balance_credits] = selected_user.company.itz_cash_company_account.balance_value
          end
          self.balances[:finly_money_card_transfer_pocket] = selected_user.wallet.balance_value
        end

        if selected_user.cards.present?
          self.balances[:cards] = []
          selected_user.cards.each do |card|
            details = ItzCash::AccountDetails.(card.user, card: card)
            self.balances[:cards] << {
                type: card.card_program.name,
                balance: details.balance,
                eligibility: details.available_card_eligibility
            }
          end
        end

        # adding vendor payment balances in this section if it is enabled for that selected_user
        if selected_user.company.vendor_payments_enabled? && selected_user.vendor_payments_enabled?
          if selected_user.vendor_payments_admin?
            self.balances[:bank_transfer_credits] = selected_user.company.yes_bank_company_account.balance_value
          end
          self.balances[:finly_money_bank_transfer_pocket] = selected_user.bank_wallet.balance_value
        end
      when 'vp'
        if selected_user.company.vendor_payments_enabled? && selected_user.vendor_payments_enabled?
          if selected_user.vendor_payments_admin?
            self.balances[:bank_transfer_credits] = selected_user.company.yes_bank_company_account.balance_value
          end
          self.balances[:finly_money_bank_transfer_pocket] = selected_user.bank_wallet.balance_value
        end
      when 'ft'
        # Adding expense management balances in this section if it's enabled for that selected_user
        if selected_user.company.expense_management_enabled? && selected_user.expense_management_enabled?
          if selected_user.admin?
            self.balances[:card_balance_credits] = selected_user.company.itz_cash_company_account.balance_value
          end
          self.balances[:finly_money_card_transfer_pocket] = selected_user.wallet.balance_value
        end
      else
        # do nothing?
    end
  end

  def post_process

  end

  def success
    params[:balances] = self.balances
    User::Balances::Show::BalancePresenter.new(user, params, messages)
  end

  class User::Balances::Show::BalancePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :balances

    def init
      self.balances = params[:balances]
    end
  end

end