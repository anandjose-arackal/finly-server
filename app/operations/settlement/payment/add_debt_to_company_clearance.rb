# action to add debt to company clearance - essentially clears company debt with cash in hand.
# params:
# to_user_id: id of the user to
# value: the value of the clearance
# currency_id:
# date: date of clearance
# note: optional note for transaction

class Settlement::Payment::AddDebtToCompanyClearance < Settlement::Base
  attr_accessor :payment

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def pre_validate
    super()
    if params[:value] and params[:value] < 0
      errors << "Reimbursement amount cannot be negative."
    end
  end

  def init
    self.to_user = user.company.users.find_by(id: params[:to_user_id])
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
    team = User::Team::Index.(user, {role_id: role, indirect_associations: true}).team
    unless team.include?(to_user)
      raise_unauthorized_exception
    end
  end

  def validate
    value = params[:value].to_f if params[:value].present?
    cash_in_hand_on_date = cash_in_hand to_user, params[:date]
    unless value <= cash_in_hand_on_date.value
      errors << 'Settlement amount cannot be greater than the cash in hand amount'
      return false
    end
  end

  def process
    balance_sheet = to_user.balance_sheet
    self.payment = to_user.payments.build(initiating_user: user, receiving_user: to_user, payment_type_id: PaymentType.debt_clearance_id, date: params[:date], note: params[:note],
                                  amount_attributes: {value: params[:value], currency_id: params[:currency_id]})
    if self.payment.save and balance_sheet.subtract_cash_in_hand(params[:value], params[:currency_id])
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