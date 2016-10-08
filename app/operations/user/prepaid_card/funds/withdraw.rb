class User::PrepaidCard::Funds::Withdraw < User::PrepaidCard::Base
  attr_accessor :from_user, :amount

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if user.cards.blank?
      add_message :error, 'Card is not assigned to the user to withdraw the funds'
    end
    if params.blank? or params[:from_user_id].blank? or params[:from_user].blank?
      add_message :error, 'Card is not assigned to the user to receive the withdrawal'
      return
    end
    if params[:password].blank?
      add_message :error, 'You will have to provide your password to complete the withdrawal'
    end
    unless user.valid_password? params[:password]
      add_message :error, 'Invalid password!'
    end
    if params[:amount].blank? or params[:amount].to_i <= 0
      add_message :error, 'Withdrawal amount cannot be less than or equal to 0'
    end
  end

  def init
    self.from_user = params[:from_user]
    if from_user.blank? and params[:from_user_id].present?
      from_user_id = params[:from_user_id]
      to_u = User.with_id(from_user_id).first rescue nil
      if to_u.present? and to_u.company_id == user.company_id
        self.from_user = to_u
      end
    end
  end

  def validate
    if from_user.blank?
      add_message :error, 'User not found'
      return
    end
    if from_user.cards.blank?
      add_message :error, 'Card is not assigned to the user to receive the withdrawal'
    end
  end

  def process
    debit_presenter = ItzCash::Debit.(from_user, amount: self.amount)
    if debit_presenter.success?
      payment_attributes = {}
      payment_attributes[:initiating_user] = user
      payment_attributes[:receiving_user] = from_user
      payment_attributes[:payment_type_id] = PaymentType.id_for(:card_transfer_receiving_debit)
      payment_attributes[:date] = Date.today
      payment_attributes[:note] = params[:note]
      payment_attributes[:amount_attributes]= {value: self.amount, currency_id: Currency.first.id }
      from_user.payments.create payment_attributes

      credit_presenter = ItzCash::Credit.(user, amount: self.amount)
      if credit_presenter.success?
        payment_attributes[:initiating_user] = from_user
        payment_attributes[:receiving_user] = user
        payment_attributes[:payment_type_id] = PaymentType.id_for(:card_transfer_initiating_credit)
        user.payments.create payment_attributes
      else
        add_message :error, credit_presenter.messages[:error]
      end
      return
    end
    add_message :error, debit_presenter.messages[:error]
  end

  def post_process
    add_message :success, "₹#{self.amount} has been withdrawn from #{from_user.name}"
  end

end
