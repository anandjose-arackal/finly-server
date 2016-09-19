# settling pending reimbursements of reports with cash in hand
# params:
# report_ids: ids of the reports that are to be reimbursed.
# to_user_id or id: user whose reports are being settled
# payment:
  # amount : value of the amount to be reimbursed - should match total of reports referenced via report_ids
  # currency_id: currency of the reimbursement
  # note: optional note to accompany payment
  # date: date of the payment

class Settlement::Payment::Settle < Settlement::Payment::Base
  attr_accessor :reports, :role

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def pre_validate
    super()
    if params[:payment][:amount] and params[:payment][:amount].to_i < 0
      messages[:error] << "Reimbursement amount cannot be negative."
    end
    if params[:report_ids].blank?
      messages[:error] << "No reports to reimburse."
      return false
    end
  end

  def init
    id = params[:to_user_id] || params[:id]
    self.to_user = user.company.users.find_by(id: id)
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
      messages[:error] << 'Reports to reimburse not found'
    end
    param = payment_params
    validate_date param[:date]

    value = nil
    value = param[:amount].to_f if param[:amount].present?
    cash_in_hand_on_date = cash_in_hand to_user, param[:date].to_date
    unless value.present? and value <= cash_in_hand_on_date.value
      messages[:error] << 'Settlement amount cannot be greater than the cash in hand amount'
      return false
    end

    # is this really necessary?
    total_amount = precision_value(reports.with_amount.sum(:value))
    unless total_amount == precision_value(param[:amount])
      messages[:error] << 'Reimbursement amount does not match report totals'
    end
  end

  def process
    param = payment_params
    self.payment = to_user.payments.build(initiating_user: user, receiving_user: to_user, payment_type_id: PaymentType.settlement_id,
                                  date: param[:date], note: param[:note],
                                  amount_attributes: {value: param[:amount], currency_id: param[:currency_id]})
    balance_sheet = to_user.balance_sheet
    if payment.save and balance_sheet.subtract_pending_reimbursement param[:amount], param[:currency_id] and balance_sheet.subtract_cash_in_hand param[:amount], param[:currency_id]
      reports.each do |report|
        Report::MarkAsReimbursed.(user, {payment: payment, report: report, role_id: role})
      end
      return true
    end
    self.messages[:error] = payment.errors.full_messages + balance_sheet.errors.full_messages
    payment.destroy
    false
  end

  def post_process
    messages[:success] << 'Debt settled against selected reports'
  end


end

