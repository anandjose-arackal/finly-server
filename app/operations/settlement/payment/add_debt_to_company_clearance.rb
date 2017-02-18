# action to add debt to company clearance - essentially clears company debt with cash in hand.
# params:
# to_user_id or id: user whose reports are being settled
# payment:
  # amount : value of the amount to be reimbursed - should match total of reports referenced via report_ids
  # currency_id: currency of the reimbursement
  # note: optional note to accompany payment
  # date: date of the payment

class Settlement::Payment::AddDebtToCompanyClearance < Settlement::Payment::Base
  attr_accessor :role

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def pre_validate
    super()
    if params[:payment][:amount].blank? or params[:payment][:amount].to_d <= 0
      add_message :error, 'Amount cannot be less than or equal to 0'
    end
    if params[:password].blank?
      add_message :error, 'You need to provide your password to initiate this transfer'
      return
    end
    unless user.valid_password?(params[:password])
      add_message :error, 'Invalid Password'
    end
  end

  def init
    self.to_user = user.company.users.find_by(id: params[:to_user_id] || params[:id])
  end

  def authorize
    unless to_user
      raise_unauthorized_exception
    end
    if user.admin?
      self.role = UserRole.admin_id
    else
      self.role = UserRole.finance_manager_id
    end
    team = User::Team::Index.(user, params)
    unless team.include?(to_user)
      raise_unauthorized_exception
    end
  end

  def validate
    value = nil
    value = payment_params[:amount].to_f if payment_params[:amount].present?
    cash_in_hand_on_date = to_user.cash_in_hand(payment_params[:date].to_date)
    unless value <= cash_in_hand_on_date.value
      add_message :error, "User does not have sufficient cash in hand on #{payment_params[:date]} for the following payment"
    end

    # validating date
    unless validate_date payment_params[:date]
      return false
    end
    
  end

  def process
    balance_sheet = to_user.balance_sheet
    self.payment = to_user.payments.build(initiating_user: user, receiving_user: to_user,
                                          payment_type_id: PaymentType.id_for(:debt_clearance),
                                          date: payment_params[:date], note: payment_params[:note],
                                  amount_attributes: {value: payment_params[:amount], currency_id: payment_params[:currency_id]})
    if self.payment.save and balance_sheet.subtract_cash_in_hand(payment_params[:amount], payment_params[:currency_id])
      return true
    end
    add_message :error, payment.errors.full_messages + balance_sheet.errors.full_messages
    payment.destroy
    false
  end

  def post_process
    add_message :success, 'Added debt to company clearance'

    Event::ESettlement::AddDebtClearance.(user, payment: self.payment)
  end
end
