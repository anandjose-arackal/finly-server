# action to add a cash advance to a particular user
# params:
# to_user_id: id of the user to whom the cash advance is to be added
# note: Optional note to include along with the cash advance
# value: Value of the amount being added to the card
# currency_id: if money is being added in a difference currency, currently defaults to 1
# date: Date on which the payment is being made

class Settlement::Payment::AddCashAdvance < Settlement::Base
  attr_accessor :payment

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def pre_validate
    super()
    if params[:payment][:amount].blank? or params[:payment][:amount] < 0
      errors << "Amount being added blank or negative."
    end
  end

  def init
    id = (params[:id] or params[:to_user_id])
    self.to_user = user.company.users.find_by(id: id)
  end

  def authorize
    unless to_user
      raise_unauthorized_exception
    end
    params[:indirect_associations] = true
    team = User::Team::Index.(user, params).team
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
                                          amount_attributes: {value: params[:amount], currency_id: params[:currency_id]})
    balance_sheet = to_user.balance_sheet
    if payment.save and balance_sheet.add_cash_in_hand(params[:amount], params[:currency_id])
      return true
    end
    self.errors = payment.errors.full_messages + balance_sheet.errors.full_messages
    payment.destroy
    return false
  end

  def success
    Settlement::Payment::Base::Presenter.new(user, self.payment)
  end

end