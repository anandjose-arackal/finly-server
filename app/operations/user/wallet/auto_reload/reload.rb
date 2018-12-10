class User::Wallet::AutoReload::Reload < BackgroundOperation
  sidekiq_options queue: 'payments_queue'

  attr_accessor :selected_user, :source_account, :auto_reload_config, :expense_card, :card_balance_value, :load_amount_value,
                :payment, :source_account_adapter

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    self.selected_user = user
    self.auto_reload_config = selected_user.auto_reload_config
    self.source_account = self.auto_reload_config.source_account
    self.expense_card = Card.find_by(id: params[:card_id])
    if expense_card && selected_user
      self.card_balance_value = ItzCash::AccountDetails.(selected_user, {card: expense_card}).balance rescue nil
      self.load_amount_value = auto_reload_config.target_balance_value - card_balance_value
    end
    self.source_account_adapter = retrieve_source_account_adapter
  end

  def validate
    # unless the card balance value was retrieved, we cannot perform the auto reload
    unless card_balance_value
      add_message :error, "Card not found, auto reload could not be perfoemed"
      return
    end

    # check if the respective card needs to be reloaded in the first place
    unless card_balance_value < auto_reload_config.threshold_balance_value
      add_message :error, "Card balance is greater than or equal to threshold balance"
      return
    end

    # check if the wallet has enough balance to reload the card
    unless precision_value(source_account_adapter.balance) >= precision_value(auto_reload_config.target_balance_value.to_f - card_balance_value.to_f)
      # update load amount value to the whatever is present in the wallet
      self.load_amount_value = source_account_adapter.balance
      if self.load_amount_value.to_f <= 0
        add_message :error, "Not enough balance in the wallet to auto-reload card"
        return
      end
    end
  end

  def authorize

  end

  def pre_process
    # determining the application for the user based on their subscriptions
    if selected_user.expense_management_enabled?
      RequestStoreUtil.set_current_app :em
    elsif selected_user.disburse_enabled?
      RequestStoreUtil.set_current_app :ft
    end
  end

  def process
    source_account = self.auto_reload_config.source_account
    payment_request = PaymentRequest.(selected_user, source_account, Card.name, :credit, :card_auto_reload)
    payment_request.add_payment_item(PaymentRequest::PaymentItem.(selected_user, expense_card, load_amount_value))
    op = AccountManager::Payments::PaymentProcessor.(selected_user, payment_request: payment_request)
    if op.success?
      self.payment = op.payment_order.payments.first
      add_message :success, "Auto reload successful!"
    else
      add_message :error, op.messages[:error]
    end
  end

  def failure
    # create notification to notify user of the fact that card could not be auto reloaded
    selected_user.notifications.create(notification_type_id: NotificationType.id_for(:payment),
                                       action_type_id: NotificationActionType.id_for(:notify_auto_reload_card_failure),
                                       action_user_id: selected_user.id,
                                       object_id: expense_card.id,
                                       object_type: "Card",
                                       read: false,
                                       timestamp: DateUtils.local_date_time,
                                       view_role_id: nil,
                                       amount_attributes: {value: load_amount_value, currency_id: 1},
                                       message: messages[:error].to_sentence,
                                       application: "em")
  end

  def success
    # create notification to notify user of the fact that card could not be auto reloaded
    selected_user.notifications.create(notification_type_id: NotificationType.id_for(:payment),
                                       action_type_id: NotificationActionType.id_for(:notify_auto_reload_card_success),
                                       action_user_id: selected_user.id,
                                       object_id: expense_card.id,
                                       object_type: "Card",
                                       path_object_id: payment.id,
                                       path_object_type: "Payment",
                                       read: false,
                                       timestamp: DateUtils.local_date_time,
                                       view_role_id: nil,
                                       amount_attributes: {value: load_amount_value, currency_id: 1},
                                       application: "em")
  end

  private

  def retrieve_source_account_adapter
    case self.source_account.class.name
      when "ItzCashCompanyAccount"
        return AccountManager::ItzCashAccount::ItzCashCompanyAccountAdapter.new(self.source_account)
      when "UserWallet"
        return AccountManager::Wallet::WalletAdapter.new(self.source_account)
      else
        # do nothing?
    end
  end

end