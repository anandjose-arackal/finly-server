class User::Summary < User::Base
  attr_accessor :selected_user, :cards, :summary

def pre_validate
    unless user.present?
      add_message :error, 'User not found'
    end
  end

  def init
    id = (params[:id] or params[:user_id])
    if personal_view? or id == user.id
      self.selected_user = user
    else
      operation = User::Team::Index.new(user, params)
      result = operation.run
      if operation.success?
        self.selected_user = result.with_id(id).first rescue nil
      else
        messages[:error] = operation.messages[:error]
      end
    end
  end

  def validate
    if selected_user.blank?
      raise_unauthorized_exception
    end
  end

  def process
    self.summary = {}
    card = nil

    if self.selected_user.cards.present?
      card = ItzCash::AccountDetails.(selected_user).card rescue nil
    end
    balances = User::Balance.(self.user, target_user: selected_user, target_user_wallet: true, virtual_account: true).balances

    summary[:card] = {}
    if self.selected_user.cards.present? and card.present?
      summary[:card][:assigned] = true
      summary[:card][:active] = card.active
      summary[:card][:balance] = card.balance
      summary[:card][:available_eligibility] = card.available_card_eligibility
    else
      summary[:card][:assigned] = false
    end

    summary[:wallet] = {balance: balances[:target_user_wallet]}

    summary[:company_credits] = balances[:virtual_account] if selected_user.company_admin?

    summary[:personal] = {}
    summary[:personal][:unreported_expenses] = selected_user.expenses.unreported.count
    summary[:personal][:unsubmitted_reports] = selected_user.reports.open.count

    if selected_user.manager?
      summary[:manager] = {}
      summary[:manager][:pending_reports] = selected_user.manager_reports.with_controlling_user_id(selected_user.id).count rescue 0
    end

    if selected_user.finance_manager?
      summary[:finance_manager] = {}
      summary[:finance_manager][:pending_reports] = selected_user.finance_reports.with_controlling_user_id(selected_user.id).count rescue 0
    end
  end

  def success
    User::Summary::Presenter.new(self.user, summary, messages)
  end

  class User::Summary::Presenter < BaseOperation::BasePresenter::SuccessPresenter

  end

end