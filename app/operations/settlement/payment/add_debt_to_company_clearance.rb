# action to add debt to company clearance - essentially clears company debt with cash in hand.
# params:
# to_user_id or id: user whose reports are being settled
# payment:
  # amount : value of the amount to be reimbursed - should match total of reports referenced via report_ids
  # currency_id: currency of the reimbursement
  # note: optional note to accompany payment
  # date: date of the payment

class Settlement::Payment::AddDebtToCompanyClearance < Settlement::Payment::Base
  attr_accessor :payment

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def pre_validate
    super()
    if params[:payment][:total].blank? or params[:payment][:total].to_i < 0
      errors << "Reimbursement cannot be negative."
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
    params[:indirect_associations] = true
    team = User::Team::Index.(user, params)
    unless team.include?(to_user)
      raise_unauthorized_exception
    end
  end

  def validate
    value = payment_params[:total].to_f if payment_params[:total].present?
    cash_in_hand_on_date = cash_in_hand to_user, payment_params[:date]
    unless value <= cash_in_hand_on_date.value
      errors << 'Settlement amount cannot be greater than the cash in hand amount'
      return false
    end
  end

  def process
    balance_sheet = to_user.balance_sheet
    self.payment = to_user.payments.build(initiating_user: user, receiving_user: to_user, payment_type_id: PaymentType.debt_clearance_id, date: payment_params[:date], note: payment_params[:note],
                                  amount_attributes: {value: payment_params[:total], currency_id: payment_params[:currency_id]})
    if self.payment.save and balance_sheet.subtract_cash_in_hand(payment_params[:total], payment_params[:currency_id])
      return true
    end
    self.errors = payment.errors.full_messages + balance_sheet.errors.full_messages
    payment.destroy
    false
  end

  def success
    Settlement::Payment::Base::Presenter.new(user, self.payment)
  end
end