class User::PrepaidCard::Funds::Credit < User::PrepaidCard::Funds::Base
  attr_accessor :amount, :credit_presenter, :to_user

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      add_message :error, 'User not found'
    end
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
    if params.blank? or (params[:id].blank? and
        params[:to_user_id].blank? and params[:to_user].blank?)
      add_message :error, 'User not found to credit the funds'
    end
  end

  def init
    self.to_user = params[:to_user]
    self.amount = params[:amount].to_i
    if to_user.blank? and (params[:to_user_id].present? or params[:id].present?)
      to_user_id = (params[:to_user_id] or params[:id])
      to_u = User.with_company_id(user.company_id).with_id(to_user_id).first rescue nil
      if to_u.present? and to_u.company_id == user.company_id
        self.to_user = to_u
      end
    end
  end

  def validate
    if to_user.blank?
      add_message :error, 'User not found'
    end
    if self.amount.blank? or self.amount <= 0
      add_message :error, 'Amount cannot be less than or equal to 0'
    end
  end

  def process
    self.credit_presenter = ItzCash::Credit.(to_user, params)
    if credit_presenter.success?
      payment_attributes = {}
      payment_attributes[:initiating_user] = user
      payment_attributes[:receiving_user] = to_user
      payment_attributes[:payment_type_id] = PaymentType.id_for(:card_credit)
      payment_attributes[:date] = DateUtils.local_date
      payment_attributes[:note] = params[:note]
      payment_attributes[:amount_attributes]= {value: self.amount, currency_id: Currency.first.id}
      self.payment = to_user.payments.create payment_attributes
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
