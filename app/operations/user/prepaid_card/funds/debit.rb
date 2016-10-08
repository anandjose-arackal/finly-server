class User::PrepaidCard::Funds::Debit < User::PrepaidCard::Credit

  def process
    self.credit_presenter = ItzCash::Debit.(selected_user, params)
    if credit_presenter.success?
      payment_attributes = {}
      payment_attributes[:initiating_user] = user
      payment_attributes[:receiving_user] = selected_user
      payment_attributes[:payment_type_id] = PaymentType.id_for(:card_debit)
      payment_attributes[:date] = Date.today
      payment_attributes[:note] = params[:note]
      payment_attributes[:amount_attributes]= {value: self.amount, currency_id: Currency.first.id }
      selected_user.payments.create payment_attributes
    else
      add_message :error, credit_presenter.messages[:error]
    end
  end

  def post_process
    add_message :success, "Successfully debited the card with ₹#{credit_presenter.amount}"
  end

end