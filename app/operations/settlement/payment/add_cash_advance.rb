# action to add a cash advance to a particular user
# params:
# to_user_id or id: user whose reports are being settled
# payment:
# amount : value of the amount to be reimbursed - should match total of reports referenced via report_ids
# currency_id: currency of the reimbursement
# note: optional note to accompany payment
# date: date of the payment

class Settlement::Payment::AddCashAdvance < Settlement::Payment::Base
  include MathUtil
  attr_accessor :money_requests, :payment_param, :role

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def pre_validate
    super()
    if params[:payment][:amount].blank? or params[:payment][:amount].to_f < 0
      add_message :error, 'Amount cannot be equal to or less than 0'
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
    id = (params[:id] or params[:to_user_id])
    team = User::Team::Index.(user, params)
    self.to_user = team.with_id(id).first rescue nil if team.present?
    money_request_id = (params[:money_request_id] or params[:money_request_ids])
    if money_request_id.present?
      self.money_requests = to_user.money_requests.with_id(money_request_id) if to_user.present?
    end
    self.payment_param = payment_params
    if user.admin? and admin_view?
      self.role = UserRole.id_for(:admin)
    else
      self.role = UserRole.id_for(:finance_manager)
    end
  end

  def authorize
    unless to_user
      raise_unauthorized_exception
    end
  end

  def validate
    unless validate_date payment_param[:date]
      # add_message :error, 'Invalid date passed. Try again'
      return false
    end
    if money_requests.present?
      total_amount = 0
      money_requests.each do |request|
        total_amount += request.total_amount
      end
      unless total_amount <= payment_param[:amount].to_f
        add_message :error, 'Payment amount cannot be less than the money requests total amount'
      end

      date = Date.parse(payment_params[:date])
      # validating date of money request against payment date
      if date < money_requests.order(submitted_at: :asc).first.updated_at.to_date
        add_message :error, 'Payment date cannot be before money request date'
      end
    end
  end

  def process
    self.payment = to_user.payments.build(initiating_user: user, receiving_user: to_user,
                                          payment_type_id: PaymentType.id_for(:add_cash_on_hand),
                                          date: payment_param[:date], note: payment_param[:note],
                                          amount_attributes: {value: payment_param[:amount],
                                                              currency_id: payment_param[:currency_id]})
    balance_sheet = to_user.balance_sheet
    if payment.save and balance_sheet.add_cash_in_hand(payment_param[:amount], payment_param[:currency_id])
      # balance_sheet.subtract_pending_reimbursement
      if money_requests.present?
        ids = money_requests.pluck(:id)
        total_amount = MoneyRequestItem.with_money_request(ids).with_amount.sum(:value)
        balance_sheet.subtract_pending_advance(total_amount)
        money_requests.each do |money_request|
          MoneyRequest::MarkAsCredited.(user, {payment: payment, money_request: money_request, role_id: role})
        end
      end
      return true
    end
    add_message :error, payment.errors.full_messages + balance_sheet.errors.full_messages
    payment.destroy
    false
  end

  def post_process
    add_message :success, 'Added cash on hand'

    Event::ESettlement::AddCashAdvance.(user, payment: self.payment)

    # recalculating user balance history for the respective day the cash was added
    unless Date.parse(payment_param[:date]) == Date.today
      balance_history = to_user.user_balance_histories.find_by(date: payment_param[:date].to_date)
      unless balance_history.blank?
        cash_on_hand_value = balance_history.cash_on_hand_balance.value
        cash_on_hand_load = balance_history.cash_on_hand_load.value
        cash_on_hand_value += payment_param[:amount]
        cash_on_hand_load += payment_param[:amount]
        balance_history.update_attributes(cash_on_hand_balance_attributes: {value: cash_on_hand_value, id: balance_history.cash_on_hand_balance.id},
                                  cash_on_hand_load_attributes: {value: cash_on_hand_load, id: balance_history.cash_on_hand_load.id})
      end
    end
  end

end
