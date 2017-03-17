class User::Balance < User::Base
  attr_accessor :target_user, :balances, :cards

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
    if params.blank?
      add_message :error, 'Nothing to load'
    end
  end

  def init
    self.target_user = (params[:target_user] or params[:user])
    if self.target_user.blank? and (params[:target_user_id].present? or params[:user_id].present? or params[:id].present?)
      user_id = (params[:target_user_id] or params[:user_id] or params[:id])
      if user_id.to_i == user.id
        self.target_user = user
      else
        self.target_user = User::Index.(user, params).team.with_id(user_id).first rescue nil
      end
    end
  end

  def validate
    if target_user.blank? and (params[:target_user_id].present? or params[:user_id].present? or params[:id].present? or
        params[:target_user].present? or params[:user].present?)
      add_message :error, 'User not found'
    end
  end

  def process
    current_user_card_assigned = user.cards.present?

    self.balances = {current_user: [], target_user: []}

    # id, name, balance

    # Virtual Account
    if params[:virtual_account] and user.company_admin?
      op = Company::VirtualAccount::Balance.(user)
      self.balances[:virtual_account] = {id: user.company.id, name: 'Company Credits', balance: op.balance} rescue nil
    end

    # Wallet
    self.balances[:current_user] << {type: :wallet, name: 'Finly Money', id: user.wallet.id, balance: User::Wallet::Balance.(user)} if params[:current_user_wallet] or params[:current_user_all]

    # Card
    if current_user_card_assigned and (params[:current_user_card] or params[:current_user_all])
      self.user.cards.each do |card|
        presenter = User::PrepaidCard::Show.(user, user: user, card_id: card.id)
        self.balances[:current_user] << {type: :card, id: card.id, name: card.card_program.name, balance: presenter.balance, eligibility: presenter.available_card_eligibility}
      end
    end

    # Cash In Hand
    self.balances[:current_user] << {type: :cash_on_hand, id: user.id, name: 'Cash On Hand', balance: (user.balance_sheet.cash_in_hand.amount_value rescue nil)} if params[:current_user_cash_in_hand] or params[:current_user_all]

    # Pending Cash Advance
    self.balances[:current_user] << {type: :pending_money_requests, id: user.id, name: 'Approved Money Requests', balance: user.balance_sheet.pending_advance.amount_value, count: user.money_requests.approved.count} if params[:current_user_pending_money_request] or params[:current_user_all]

    # pending approved reports
    if params[:current_user_pending_reports] or params[:current_user_all]
      total = 0
      user.reports.approved.each do |report|
        total += report.total_amount(:only_manual_expenses)
      end

      self.balances[:current_user] << {type: :pending_reports, id: user.id, name: 'Approved Reports', balance: total, count: user.reports.approved.count}
    end

    if target_user.present?
      personal = user == target_user
      target_user_card_assigned = target_user.cards.present?

      # Wallet
      self.balances[:target_user] << {type: :wallet, name: 'Finly Money', id: target_user.wallet.id, balance: User::Wallet::Balance.(user, for_user: target_user, view: params[:view])} if params[:target_user_wallet] or params[:target_user_all]

      # Card
      if target_user_card_assigned and (params[:target_user_card] or params[:target_user_all])
        self.target_user.cards.each do |card|
          return unless personal or card.card_program.manager_view_balance or card.card_program.manager_view_eligibility
          presenter = User::PrepaidCard::Show.(user, user: target_user, card_id: card.id, view: params[:view])
          show_balance = (personal or card.card_program.manager_view_balance)
          show_eligibility = (personal or card.card_program.manager_view_eligibility)
          balance = nil
          eligibility = nil
          if show_balance
            balance = presenter.balance
          end
          if show_eligibility
            eligibility = presenter.available_card_eligibility
          end
          creditable = ((personal and card.card_program.personal_wallet_fund_transfer) or (!personal and card.card_program.manager_credit))
          debitable = ((personal and card.card_program.personal_wallet_fund_transfer) or (!personal and card.card_program.manager_debit))
          self.balances[:target_user] << {type: :card, id: card.id, name: card.card_program.name, show_balance: show_balance,
                                          balance: balance, show_eligibility: show_eligibility, eligibility: eligibility,
                                          creditable: creditable, debitable: debitable}
        end
      end

      # Cash In Hand
      self.balances[:target_user] << {type: :cash_on_hand, id: target_user.id, name: 'Cash On Hand', balance: (target_user.balance_sheet.cash_in_hand.amount_value rescue nil)} if params[:target_user_cash_in_hand] or params[:target_user_all]

      # Pending Cash Advance
      self.balances[:target_user] << {type: :pending_money_requests, id: target_user.id, name: 'Approved Money Requests', balance: target_user.balance_sheet.pending_advance.amount_value, count: target_user.money_requests.approved.count} if params[:target_user_pending_money_request] or params[:target_user_all]

      # pending approved reports
      if params[:target_user_pending_reports] or params[:target_user_all]
        total = 0
        target_user.reports.approved.each do |report|
          total += report.total_amount(:only_manual_expenses)
        end

        self.balances[:target_user] << {type: :pending_reports, id: target_user.id, name: 'Approved Reports', balance: total, count: target_user.reports.approved.count}
      end
    end

  end

  def success
    User::Balance::SuccessPresenter.new(user, {target_user: target_user, balances: self.balances, cards: self.cards}, messages)
  end

  class User::Balance::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :target_user, :balances, :cards

    def init
      self.target_user = params[:target_user]
      self.balances = params[:balances]
      self.cards = params[:cards]
    end

  end

end
