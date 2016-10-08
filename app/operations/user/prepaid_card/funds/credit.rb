class User::PrepaidCard::Funds::Credit < User::PrepaidCard::Base
  attr_accessor :amount, :credit_presenter

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def pre_validate
    super
    return if has_errors?
    unless user.company_admin?
      add_message :error, 'You do not have the permission to perform this action'
    end
    if params[:amount].blank?
      add_message :error, 'Amount cannot be blank'
      return
    end
    if params[:password].blank?
      add_message :error, 'You need to provide your password to load the funds'
    elsif not user.valid_password?(params[:password])
      add_message :error, 'Invalid Password!'
    end
  end

  def init
    super
    self.amount = params[:amount].to_i rescue nil
  end

  def validate
    super
    if self.amount.blank? or self.amount <= 0
      add_message :error, 'Amount cannot be less than or equal to 0'
    end
  end

  def process
    self.credit_presenter = ItzCash::Credit.(selected_user, params)
    if credit_presenter.success?
      payment_attributes = {}
      payment_attributes[:initiating_user] = user
      payment_attributes[:receiving_user] = selected_user
      payment_attributes[:payment_type_id] = PaymentType.id_for(:card_credit)
      payment_attributes[:date] = Date.today
      payment_attributes[:note] = params[:note]
      payment_attributes[:amount_attributes]= {value: self.amount, currency_id: Currency.first.id }
      user.payments.create payment_attributes
    else
      add_message :error, credit_presenter.messages[:error]
    end
  end

  def post_process
    if self.credit_presenter.present? and self.credit_presenter.success?
      add_message :success, "Successfully credited the card with ₹#{amount}"
    end
  end

end
