# action to reimburse a bunch of reports in one shot
# params:
# report_ids: ids of the reports that are to be reimbursed.
# to_user_id or id: user whose reports are being settled
# payment:
  # amount : value of the amount to be reimbursed - should match total of reports referenced via report_ids
  # currency_id: currency of the reimbursement
  # note: optional note to accompany payment
  # date: date of the payment

class Settlement::Payment::AddReimbursement < Settlement::Payment::Base
  include MathUtil
  attr_accessor :reports, :role

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def pre_validate
    super()
    if params[:payment][:amount] and params[:payment][:amount].to_d <= 0
      add_message :error, 'Reimbursement amount cannot be less than or equal to 0'
      return
    end
    if params[:report_ids].blank?
      add_message :error, 'No reports to reimburse'
    end
    # if params[:password].blank?
    #   add_message :error, 'You need to provide your password to initiate this transfer'
    #   return
    # end
    # unless user.valid_password?(params[:password])
    #   add_message :error, 'Invalid Password'
    # end
  end

  def init
    id = (params[:id] or params[:to_user_id])
    self.to_user = user.company.users.find_by(id: id)
    self.reports = to_user.reports.with_id(params[:report_ids]) if to_user
  end

  def authorize
    unless to_user
      raise_unauthorized_exception
    end
    if reports.blank?
      raise_unauthorized_exception
    end
    if user.admin? and admin_view?
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
    validate_date payment_params[:date]

    # is this really necessary
    total_amount = precision_value(reports.with_amount.sum(:value)).to_f
    unless total_amount == precision_value(payment_params[:amount]).to_f
      add_message :error, 'Reimbursement amount does not match report totals'
    end
  end

  def process
    self.payment = to_user.payments.build(initiating_user: user, receiving_user: to_user,
                                          payment_type_id: PaymentType.id_for(:reimbursement),
                                          date: payment_params[:date], note: payment_params[:note],
                                  amount_attributes: {value: payment_params[:amount], currency_id: payment_params[:currency_id]})
    balance_sheet = to_user.balance_sheet
    if payment.save and balance_sheet.subtract_pending_reimbursement precision_value(payment_params[:amount]), payment_params[:currency_id]
      reports.each do |report|
        Report::MarkAsReimbursed.(user, {payment: payment, report: report, role_id: role})
      end
      return true
    end
    add_message :error, payment.errors.full_messages + balance_sheet.errors.full_messages
    payment.destroy
  end

  def post_process
    add_message :success, 'Reports reimbursed'

    Event::ESettlement::AddReimbursement.(user, payment: self.payment)
  end
end