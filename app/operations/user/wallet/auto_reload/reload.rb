class User::Wallet::AutoReload::Reload < BackgroundOperation

  attr_accessor :selected_user, :wallet, :auto_reload_config, :expense_card, :card_balance_value, :load_amount_value,
                :payment

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    self.selected_user = user
    self.wallet = selected_user.wallet
    self.auto_reload_config = selected_user.auto_reload_config
    self.expense_card = Card.find_by(id: params[:card_id])
    if expense_card && selected_user
      self.card_balance_value = ItzCash::AccountDetails.(selected_user, {card_id: expense_card.id}).balance rescue nil
      self.load_amount_value = auto_reload_config.minimum_balance_value - card_balance_value
    end
  end

  def validate
    # unless the card balance value was retrieved, we cannot perform the auto reload
    unless card_balance_value
      add_message :error, "Card not found, auto reload could not be perfoemed"
      return
    end

    # check if the respective card needs to be reloaded in the first place
    unless card_balance_value < auto_reload_config.minimum_balance_value
      add_message :error, "Minimum balance is less than card balance"
      return
    end

    # check if the wallet has enough balance to reload the card
    unless precision_value(wallet.balance_value) >= precision_value(auto_reload_config.minimum_balance_value.to_f - card_balance_value.to_f)
      add_message :error, "Not enough balance in the wallet to auto-reload card"
      return
    end

  end

  def authorize

  end

  def process
    credit_presenter = ItzCash::Credit.(selected_user, card_id: expense_card.id, amount: load_amount_value)
    if credit_presenter.success?
      wallet.subtract_funds(load_amount_value)
      # Reduce company wallet balance when funds are transferred from wallet to card
      selected_user.company.account.funds_debited_from_wallet(self.load_amount_value)
      # creating a payment for the respective card and wallet reload
      self.payment = Payment.new(initiating_user: selected_user,
                            receiving_user: selected_user,
                            date: DateUtils.local_date,
                            note: "Auto reload of Card from Wallet",
                            payment_type_id: PaymentType.id_for(:credit),
                            amount_attributes: {value: self.load_amount_value, currency_id: Currency.first.id},
                            initiating_account: selected_user.wallet,
                            receiving_account: expense_card,
                            payment_status_id: PaymentStatus.id_for(:completed))
      payment.save
      add_message :success, 'Auto reload successful'
    else
      add_message :error, credit_presenter.messages[:error]
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
                                       message: messages[:error].to_sentence)
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
                                       amount_attributes: {value: load_amount_value, currency_id: 1})
  end

end