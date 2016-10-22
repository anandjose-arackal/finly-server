require "#{Rails.root}/app/operations/settlement/index"
class Settlement::Show < Settlement::Base
  attr_accessor :selected_user, :reports, :payments, :money_requests, :actions, :type, :view_to_load

  def pre_validate
    unless user.present?
      messages[:error] << 'User not found'
    end
    unless params[:view_to_load].present?
      messages[:error] << 'Error loading reports'
    end
  end

  def init
    self.type = {}
    self.view_to_load = params[:view_to_load]
  end

  def process
    load_selected_user
    return if has_errors?
    if self.view_to_load == 'payments'
      load_payments
    elsif self.view_to_load.include?('money_request')
      load_money_requests
    else
      load_reports
    end
    return if has_errors?
    self.type[view_to_load.to_sym] = true
    load_actions
  end

  def success
    params[:selected_user] = selected_user
    params[:reports] = reports
    params[:payments] = payments
    params[:money_requests] = money_requests
    params[:actions] = actions
    params[:type] = type
    Settlement::Show::Presenter.new(user, params, messages)
  end

  class Settlement::Show::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :selected_user, :items, :actions, :type

    def init
      self.selected_user = params[:selected_user]
      self.items = (params[:reports] or params[:payments] or params[:money_requests])
      self.actions = params[:actions]
      self.type = params[:type]
    end

    def reimbursement_amount_for_report(report)
      return 0 unless report.present?
      if report.reimbursement_amount.present?
        report.reimbursement_amount.value
      else
        0
      end
    end
  end

  private
  def load_selected_user
    if personal_view?
      self.selected_user = self.user
      return
    end
    user_op = Settlement::Index.new(user, params)
    user_result = user_op.run
    unless user_op.success?
      self.messages[:error] = user_op.messages[:error]
      return
    end
    user_id = (params[:id] or params[:user_id])
    self.selected_user = user_result.users.with_id(user_id).first rescue nil
    if self.selected_user.blank?
      messages[:error] << 'User not found'
    end
  end

  def load_reports
    if self.view_to_load.blank?
      self.reports = self.selected_user.reports
    else
      self.reports = self.selected_user.reports
      self.reports = self.reports.send(self.view_to_load) if self.reports.present?
    end
  end

  def load_payments
    self.payments = self.selected_user.payments.with_details
  end

  def load_money_requests
    if self.view_to_load.blank?
      self.money_requests = selected_user.money_requests
    else
      self.money_requests = self.selected_user.money_requests
      self.money_requests = self.money_requests.send(self.view_to_load) if self.money_requests.present?
    end
  end

  def load_actions
    return unless admin_view? or finance_view?
    return if self.selected_user.id == user.id and not admin_view?
    self.actions = {}
    self.actions[:credit_reimbursement] = Rails.application.routes.url_helpers.settlements_path(id: selected_user.id, payment_type: PaymentType.id_for(:reimbursement).to_s)
    # self.actions[:credit_settle] = Rails.application.routes.url_helpers.settlements_path(id: selected_user.id, payment_type: PaymentType.id_for(:settlement))
    # self.actions[:debit_settle] = Rails.application.routes.url_helpers.settlements_path(id: selected_user.id, payment_type: PaymentType.id_for(:settlement))
    self.actions[:debit_cash_advance] = Rails.application.routes.url_helpers.settlements_path(id: selected_user.id, payment_type: PaymentType.id_for(:debt_clearance))
    self.actions[:credit_cash_advance] = Rails.application.routes.url_helpers.settlements_path(id: selected_user.id, payment_type: PaymentType.id_for(:advance))
    self.actions[:credit_money_request] = Rails.application.routes.url_helpers.settlements_path(id: selected_user.id, payment_type: PaymentType.id_for(:advance))

    if self.selected_user.cards.present?
      credit_params = {}
      credit_params[:view] = params[:view]
      credit_params[:action_type] = User::Wallet::Base::ACTIONS[:credit]
      credit_params[:to_user_id] = selected_user.id

      debit_params = {}
      debit_params[:view] = params[:view]
      debit_params[:action_type] = User::Wallet::Base::ACTIONS[:debit]
      debit_params[:from_user_id] = selected_user.id

      # Wallet Actions
      if manager_view? or finance_view? or admin_view?
        if admin_view?
          # Virtual Account -> Wallet
          credit_params[:from_account] = :virtual_account
          credit_params[:to_account] = :wallet
          actions[:credit_wallet_from_virtual_account] = Rails.application.routes.url_helpers.update_balance_path(credit_params)

          # Virtual Account -> Card
          credit_params[:from_account] = :virtual_account
          credit_params[:to_account] = :card
          actions[:credit_card_from_virtual_account] = Rails.application.routes.url_helpers.update_balance_path(credit_params)

          # Wallet -> Virtual Account
          debit_params[:from_account] = :wallet
          debit_params[:to_account] = :virtual_account
          actions[:debit_wallet_to_virtual_account] = Rails.application.routes.url_helpers.update_balance_path(debit_params)
        end
        if selected_user != user
          # Wallet -> Wallet
          credit_params[:from_account] = :wallet
          credit_params[:to_account] = :wallet
          actions[:credit_wallet_from_wallet] = Rails.application.routes.url_helpers.update_balance_path(credit_params)

          # Wallet -> Wallet
          debit_params[:from_account] = :wallet
          debit_params[:to_account] = :wallet
          actions[:debit_wallet_to_wallet] = Rails.application.routes.url_helpers.update_balance_path(debit_params)
        end
      end

      # Wallet -> Card
      credit_params[:from_account] = :wallet
      credit_params[:to_account] = :card
      actions[:credit_card_from_wallet] = Rails.application.routes.url_helpers.update_balance_path(credit_params)
      # Wallet Actions End


      # Card Actions
      card = self.selected_user.cards.first
      if manager_view? or finance_view? or admin_view?
        card_params = {}
        card_params[:view] = params[:view]
        card_params[:user_id] = selected_user.id
        card_params[:action_type] = nil
        if card.active
          card_params[:status_type] = User::PrepaidCard::Base::STATUS[:block]
          actions[:deactivate_card] = Rails.application.routes.url_helpers.update_card_status_path(card_params)
        else
          card_params[:status_type] = User::PrepaidCard::Base::STATUS[:unblock]
          actions[:activate_card] = Rails.application.routes.url_helpers.update_card_status_path(card_params)
        end
      else
        if card.active
          card_params = {status_type: User::PrepaidCard::Base::STATUS[:block], user_id: selected_user.id}
          actions[:deactivate_card] = Rails.application.routes.url_helpers.update_card_status_path(card_params)
        else
          if card.disabled_by_role_id == UserRole.id_for(:employee)
            card_params = {status_type: User::PrepaidCard::Base::STATUS[:unblock], user_id: selected_user.id}
            actions[:activate_card] = Rails.application.routes.url_helpers.update_card_status_path(card_params)
          end
        end
      end
    end
  end

end