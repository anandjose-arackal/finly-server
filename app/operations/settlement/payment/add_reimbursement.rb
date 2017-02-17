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
  attr_accessor :reports, :role, :report_total, :cash_deduction, :report_names

  attr_accessor :reimbursement_amount, :cash_in_hand_deduction_amount

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def pre_validate
    super()
    if params[:payment][:from_cash_in_hand].to_f <0 or params[:payment][:from_outside_finly].to_f < 0
      add_message :error, "Reimbursement amount or cash in hand deduction cannot be negative"
      return
    end
    if params[:payment][:from_cash_in_hand].to_f == 0 and params[:payment][:from_outside_finly].to_f == 0
      add_message :error, 'Reimbursement amount and cash in hand deduction cannot both be equal to 0'
      return
    end
    if params[:report_ids].blank?
      add_message :error, 'No reports to reimburse'
    end
  end

  def init
    id = (params[:id] or params[:to_user_id])
    self.to_user = user.company.users.find_by(id: id)
    self.reports = to_user.reports.with_id(params[:report_ids]) if to_user
    self.report_names = []
    reports.each do |report|
      self.report_names << report.name
    end
    self.reimbursement_amount = payment_params[:from_outside_finly].to_f
    self.cash_in_hand_deduction_amount = payment_params[:from_cash_in_hand].to_f
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
    team = User::Team::Index.(user, params)
    unless team.include?(to_user)
      raise_unauthorized_exception
    end
  end

  def validate
    unless validate_date payment_params[:date]
      return false
    end

    if params[:password].blank?
      add_message :error, 'You need to provide your password to initiate this transfer'
      return
    end
    unless user.valid_password?(params[:password])
      add_message :error, 'Invalid Password'
      return
    end

    payment_date = Date.parse(payment_params[:date])
    # validating that the money deducted from cash in hand is actually less than the cash in hand on date of reimbursement
    cash_in_hand = to_user.cash_in_hand(payment_date).value rescue 0

    if precision_value(cash_in_hand_deduction_amount) > precision_value(cash_in_hand)
      add_message :error, "You cannot deduct more cash than the employee has on #{payment_params[:date].to_s}"
    end
    # checking if cash in hand deduction + reimbursement amount matches up with report total
    self.report_total = precision_value(reports.with_reimbursement_amount.sum(:value)).to_f
    unless report_total == precision_value(reimbursement_amount + cash_in_hand_deduction_amount).to_f
      add_message :error, 'Reimbursement total does not match report totals'
    end
  end

  def process
    self.payment = to_user.payments.build(initiating_user: user, receiving_user: to_user,
                                          payment_type_id: PaymentType.id_for(:reimbursement),
                                          date: payment_params[:date], note: payment_params[:note],
                                  amount_attributes: {value: reimbursement_amount, currency_id: payment_params[:currency_id]})
    # deducting cash in hand given in the params
    self.cash_deduction = to_user.payments.build(initiating_user: user, receiving_user: to_user,
                                                 payment_type_id: PaymentType.id_for(:debt_clearance),
                                                 date: payment_params[:date], note: "Reimbursement deduction for reports: #{report_names.to_sentence}",
                                                 amount_attributes: {value: cash_in_hand_deduction_amount, currency_id: payment_params[:currency_id]})
    balance_sheet = to_user.balance_sheet
    if reimbursement_amount == 0
      if cash_deduction.save and balance_sheet.subtract_pending_reimbursement report_total, Currency.first.id
        # subtract the respective amount from the user's cash in hand
        to_user.balance_sheet.subtract_cash_in_hand(cash_in_hand_deduction_amount)
        # mark the reports as reimbursed
        reports.each do |report|
          Report::MarkAsReimbursed.(user, {from_cash_in_hand: cash_deduction, report: report, role_id: role, status: ReportStatus.closed_id})
        end
        return
      else
        add_message :error, cash_deduction.errors.full_messages + balance_sheet.errors.full_messages
      end
    elsif cash_in_hand_deduction_amount == 0
      if payment.save and balance_sheet.subtract_pending_reimbursement report_total, Currency.first.id
        # mark the reports as reimbursed
        reports.each do |report|
          Report::MarkAsReimbursed.(user, {payment: payment, report: report, role_id: role})
        end
      else
        add_message :error, payment.errors.full_messages + balance_sheet.errors.full_messages
      end
    else
      if payment.save and cash_deduction.save and balance_sheet.subtract_pending_reimbursement report_total, Currency.first.id
        # subtract the respective amount from the user's cash in hand
        to_user.balance_sheet.subtract_cash_in_hand(payment_params[:from_cash_in_hand].to_f)
        # mark all the reports as reimbursed
        reports.each do |report|
          Report::MarkAsReimbursed.(user, {payment: payment, from_cash_in_hand: cash_deduction, report: report, role_id: role})
        end
      else
        add_message :error, payment.errors.full_messages + cash_deduction.errors.full_messages + balance_sheet.errors.full_messages
      end
    end
  end

  def post_process
    add_message :success, 'Reports reimbursed'

    event = Event::ESettlement::AddReimbursement.new(user, payment: self.payment, cash_in_hand_deduction: cash_deduction, from_cash_in_hand: cash_deduction)
    event.run
  end
end
