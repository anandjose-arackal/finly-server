class User::PrepaidCard::Funds::Transfer < User::PrepaidCard::Funds::Base
  attr_accessor :to_user, :amount

  def authorized_user_types
    [:manager,:finance_manager, :admin]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if user.cards.blank?
      add_message :error, 'You have not been assigned a card to transfer the withdrawn funds'
      return
    end
    if params.blank? or (params[:to_user_id].blank? and params[:to_user].blank?)
      add_message :error, 'User not found to credit the funds'
      return
    end
    if params[:password].blank?
      add_message :error, 'You will have to provide your password to complete the transfer'
    end
    unless user.valid_password? params[:password]
      add_message :error, 'Invalid password!'
    end
    if params[:amount].blank? or params[:amount].to_i <= 0
      add_message :error, 'Transfer amount cannot be less than or equal to 0'
    end
  end

  def init
    self.to_user = params[:to_user]
    self.amount = params[:amount].to_i
    if to_user.blank? and params[:to_user_id].present?
      to_user_id = params[:to_user_id]
      to_u = User.with_company_id(user.company_id).with_id(to_user_id).first rescue nil
      if to_u.present? and to_u.company_id == user.company_id
        self.to_user = to_u
      end
    end
  end

  def validate
    if to_user.blank?
      add_message :error, 'User not found'
      return
    end
    if to_user.cards.blank?
      add_message :error, 'Card is not assigned to the user to receive the funds'
    end
    if to_user.id == user.id
      add_message :error, 'You cannot transfer funds to your own card'
    end
  end

  def process
    debit_presenter = ItzCash::Debit.(user, amount: self.amount)
    if debit_presenter.success?
      payment_attributes = {}
      payment_attributes[:initiating_user] = to_user
      payment_attributes[:receiving_user] = user
      payment_attributes[:payment_type_id] = PaymentType.id_for(:card_transfer_initiating_debit)
      payment_attributes[:date] = DateUtils.local_date
      payment_attributes[:note] = params[:note]
      payment_attributes[:amount_attributes]= {value: self.amount, currency_id: Currency.first.id}
      user.payments.create payment_attributes

      credit_presenter = ItzCash::Credit.(to_user, amount: self.amount)
      if credit_presenter.success?
        payment_attributes[:initiating_user] = user
        payment_attributes[:receiving_user] = to_user
        payment_attributes[:payment_type_id] = PaymentType.id_for(:card_transfer_receiving_credit)
        self.payment = to_user.payments.create payment_attributes
      else
        add_message :error, credit_presenter.messages[:error]
      end
      return
    end
    add_message :error, debit_presenter.messages[:error]
  end

  def post_process
    add_message :success, "₹#{self.amount} has been transferred to #{to_user.name}"
  end

end
