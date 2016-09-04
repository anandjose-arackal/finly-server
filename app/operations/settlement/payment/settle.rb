# settling pending reimbursements of reports with cash in hand
# params:
# to_user_id: user whose reports are being settled
# report_id: ids of the reports that are to be reimbursed.
# value : value of the amount to be reimbursed - should match total of reports referenced via report_ids
# currency_id: currency of the reimbursement

class Settlement::Payment::Settle < Settlement::Base


  def authorized_user_types
    [:finance_manager, :admin]
  end

  def pre_validate
    super()
    if params[:value] and params[:value] < 0
      errors << "Reimbursement amount cannot be negative."
    end
    if params[:report_id].blank?
      errors << "No reports to reimburse."
      return false
    end
  end

  def init
    self.to_user = user.company.users.find_by(id: params[:to_user_id])
    self.reports = to_user.reports.where(id: params[:report_id]) if to_user
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
    if reports.blank?
      errors << "Reports to reimburse not found."
    end
    validate_date params[:date]

    value = params[:value].to_f if params[:value].present?
    cash_in_hand_on_date = cash_in_hand to_user, params[:date]
    unless value <= cash_in_hand_on_date.value
      errors << 'Settlement amount cannot be greater than the cash in hand amount'
      return false
    end

    # is this really necessary?
    total_amount = precision_value(reports.sum(:value))
    unless total_amount == params[:value]
      errors << "Reimbursement amount does not match report totals."
    end
  end

  def process
    payment = to_user.payments.build(initiating_user: user, receiving_user: to_user, payment_type_id: PaymentType.settlement_id,
                                  date: params[:date], note: params[:note],
                                  amount_attributes: {value: params[:value], currency_id: params[:currency_id]})
    balance_sheet = to_user.balance_sheet
    if payment.save and balance_sheet.subtract_pending_reimbursement value, currency and balance_sheet.subtract_cash_in_hand value, currency
      reports.each do |report|
        Report::MarkAsReimbursed.new(user, {payment_id: payment.id, report_id: report.id}).run
      end
      return true
    end
    self.errors = payment.errors.full_messages + balance_sheet.errors.full_messages
    payment.destroy
    false
  end

  def post_process
    # mailer
  end


end

