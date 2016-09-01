# action to add a cash advance to a particular user
# params:
# to_user_id: id of the user to whom the cash advance is to be added
# note: Optional note to include along with the cash advance
# value: Value of the amount being added to the card
# currency_id: if money is being added in a difference currency, currently defaults to 1
# date: Date on which the payment is being made

class Settlement::AddCashAdvance < Settlement::Base


  attr_accessor :payment

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def pre_validate
    super()
    if params[:value].blank? or params[:value] < 0
      errors << "Amount being added blank or negative."
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
      role = UserRole.admin_id
    else
      role = UserRole.finance_manager_id
    end
    team = User::Team::Show.(user, role, indirect_associations: true).team
    unless team.include?(to_user)
      raise_unauthorized_exception
    end
  end

  def validate
    unless validate_date params[:date]
      errors << "Invalid date passed. Try again."
    end
  end

  def process
    self.payment = to_user.payments.build(initiating_user: user, receiving_user: to_user, payment_type_id: PaymentType.advance_id, date: params[:date], note: params[:note],
                                  amount_attributes: {value: params[:value], currency_id: params[:currency_id]})
    balance_sheet = to_user.balance_sheet
    if payment.save and balance_sheet.add_cash_in_hand(params[:value], params[:currency_id])
      return true
    end
    self.errors = payment.errors.full_messages + balance_sheet.errors.full_messages
    payment.destroy
    return false
  end

  def post_process
    # mailer
  end

  def retrieve
    if is_success?
      return payment
    else
      return false
    end
  end

end