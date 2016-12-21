class User::PrepaidCard::Funds::Debit < User::PrepaidCard::Funds::Credit

  def pre_validate
    params[:to_user] = params[:from_user] if params[:from_user].present?
    params[:to_user_id] = params[:from_user_id] if params[:from_user_id].present?
    super
  end 

  def process
    self.credit_presenter = ItzCash::Debit.(to_user, params)
    if credit_presenter.success?
      payment_attributes = {}
      payment_attributes[:initiating_user] = user
      payment_attributes[:receiving_user] = to_user
      payment_attributes[:payment_type_id] = PaymentType.id_for(:card_debit)
      payment_attributes[:date] = DateUtils.local_date
      payment_attributes[:note] = params[:note]
      payment_attributes[:amount_attributes]= {value: self.amount, currency_id: Currency.first.id}
      self.payment = to_user.payments.create payment_attributes
    else
      add_message :error, credit_presenter.messages[:error]
    end
  end

  def post_process
    add_message :success, "Successfully debited the card with ₹#{credit_presenter.amount}"
  end

end