# action to add a cash advance to a particular user
# params:
# to_user_id or id: user whose reports are being settled
# payment:
  # amount : value of the amount to be reimbursed - should match total of reports referenced via report_ids
  # currency_id: currency of the reimbursement
  # note: optional note to accompany payment
  # date: date of the payment

class Settlement::Payment::AddCashAdvance < Settlement::Payment::Base
  attr_accessor :payment

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def pre_validate
    super()
    if params[:payment][:amount].blank? or params[:payment][:amount].to_i < 0
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
    team = User::Team::Index.(user, params)
    unless team.include?(to_user)
      raise_unauthorized_exception
    end
  end

  def validate
    unless validate_date payment_params[:date]
      errors << "Invalid date passed. Try again."
    end
  end

  def process
    self.payment = to_user.payments.build(initiating_user: user, receiving_user: to_user, payment_type_id: PaymentType.advance_id, date: payment_params[:date], note: params[:note],
                                          amount_attributes: {value: payment_params[:amount], currency_id: payment_params[:currency_id]})
    balance_sheet = to_user.balance_sheet
    if payment.save and balance_sheet.add_cash_in_hand(payment_params[:amount], payment_params[:currency_id])
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