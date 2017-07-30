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
    self.amount = payment_params[:amount]
    self.currency_id = payment_params[:currency_id] || Currency.first.id
    init_payment_request(PaymentType.id_for(:deduct_cash_on_hand))
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
    # validating date
    unless validate_date payment_params[:date]
      return false
    end

  end

  def process
    op = AccountManager::Payments::PaymentProcessor.(user, payment_request: payment_request)
    if op.success?
      return true
    end
    add_message :error, op.messages[:error]
    false
  end

  def post_process
    add_message :success, 'Deducted cash on hand'

    Event::ESettlement::AddDebtClearance.(user, payment: self.payment)

    # recalculating user balance history for the respective day the cash was deducted
    unless Date.parse(payment_params[:date]) == Date.today
      balance_history = to_user.user_balance_histories.find_by(date: payment_params[:date].to_date)
      unless balance_history.blank?
        cash_on_hand_value = balance_history.cash_on_hand_balance.value
        cash_on_hand_withdrawal = balance_history.cash_on_hand_withdrawal.value
        cash_on_hand_value -= payment_params[:amount].to_f
        cash_on_hand_withdrawal += payment_params[:amount].to_f
        balance_history.update_attributes(cash_on_hand_balance_attributes: {value: cash_on_hand_value, id: balance_history.cash_on_hand_balance.id},
                                          cash_on_hand_withdrawal_attributes: {value: cash_on_hand_withdrawal, id: balance_history.cash_on_hand_withdrawal.id})
      end
    end
  end
end
