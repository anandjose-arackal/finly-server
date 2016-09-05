# settling pending reimbursements of reports with cash in hand
# params:
# report_ids: ids of the reports that are to be reimbursed.
# to_user_id or id: user whose reports are being settled
# payment:
  # amount : value of the amount to be reimbursed - should match total of reports referenced via report_ids
  # currency_id: currency of the reimbursement
  # note: optional note to accompany payment
  # date: date of the payment

class Settlement::Payment::Settle < Settlement::Base
  attr_accessor :payment

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def pre_validate
    super()
    if params[:payment][:amount] and params[:payment][:amount] < 0
      errors << "Reimbursement amount cannot be negative."
    end
    if params[:report_ids].blank?
      errors << "No reports to reimburse."
      return false
    end
  end

  def init
    self.to_user = user.company.users.find_by(id: params[:to_user_id])
    self.reports = to_user.reports.where(id: params[:report_ids]) if to_user
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
    if reports.blank?
      errors << "Reports to reimburse not found."
    end
    validate_date payment_params[:date]

    value = payment_params[:amount].to_f if payment_params[:amount].present?
    cash_in_hand_on_date = cash_in_hand to_user, payment_params[:date]
    unless value <= cash_in_hand_on_date.value
      errors << 'Settlement amount cannot be greater than the cash in hand amount'
      return false
    end

    # is this really necessary?
    total_amount = precision_value(reports.sum(:value))
    unless total_amount == payment_params[:amount]
      errors << "Reimbursement amount does not match report totals."
    end
  end

  def process
    self.payment = to_user.payments.build(initiating_user: user, receiving_user: to_user, payment_type_id: PaymentType.settlement_id,
                                  date: payment_params[:date], note: payment_params[:note],
                                  amount_attributes: {value: payment_params[:amount], currency_id: payment_params[:currency_id]})
    balance_sheet = to_user.balance_sheet
    if payment.save and balance_sheet.subtract_pending_reimbursement payment_params[:amount], currency and balance_sheet.subtract_cash_in_hand payment_params[:amount], currency
      reports.each do |report|
        Report::MarkAsReimbursed.new(user, {payment_id: payment.id, report_id: report.id}).run
      end
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

