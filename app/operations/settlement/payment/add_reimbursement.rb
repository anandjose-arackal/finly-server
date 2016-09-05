# action to reimburse a bunch of reports in one shot
# params:
# to_user_id: user whose reports are being reimbursed
# report_id: ids of the reports that are to be reimbursed.
# value : value of the amount to be reimbursed - should match total of reports referenced via report_ids
# currency_id: currency of the reimbursement
# date: date on which the reimbursement is being added
# note: optional note while adding reimbursement

class Settlement::Payment::AddReimbursement < Settlement::Base
  include MathUtil

  attr_accessor :payment,:reports, :role

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def pre_validate
    super()
    if params[:value] and params[:value] < 0
      errors << "Reimbursement amount cannot be negative."
      return false
    end
    if params[:report_id].blank?
      errors << "No reports to reimburse."
      return false
    end
  end

  def init
    id = (params[:id] or params[:to_user_id])
    self.to_user = user.company.users.find_by(id: id)
    self.reports = to_user.reports.where(id: params[:report_id]) if to_user
  end

  def authorize
    unless to_user
      raise_unauthorized_exception
    end
    if reports.blank?
      raise_unauthorized_exception
    end
    if user.admin?
      self.role = UserRole.admin_id
    else
      self.role = UserRole.finance_manager_id
    end
    team = User::Team::Index.(user, role, indirect_associations: true).team
    unless team.include?(to_user)
      raise_unauthorized_exception
    end
  end

  def validate
    validate_date payment_params[:date]

    # is this really necessary
    total_amount = precision_value(reports.with_amount.sum(:value))
    unless total_amount == precision_value(payment_params[:amount])
      errors << "Reimbursement amount does not match report totals."
    end
  end

  def process
    self.payment = to_user.payments.build(initiating_user: user, receiving_user: to_user, payment_type_id: PaymentType.reimbursement_id, date: payment_params[:date], note: payment_params[:note],
                                  amount_attributes: {value: payment_params[:amount], currency_id: payment_params[:currency_id]})
    balance_sheet = to_user.balance_sheet
    if payment.save and balance_sheet.subtract_pending_reimbursement precision_value(payment_params[:amount]), payment_params[:currency_id]
      reports.each do |report|
        Report::MarkAsReimbursed.new(user, {payment_id: payment.id, report_id: report.id, role_id: role}).run
      end
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