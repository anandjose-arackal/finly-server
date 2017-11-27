# action that recomputes settlement once a report is unapproved
# user passed must be report owner and NOT report person unapproving it
# params:
# report_id: id of the report that is being unapproved


class Settlement::SReport::Unapproved < Report::Base
  attr_accessor :report

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or params passed."
    end
  end

  def init
    self.report = params[:report]
  end

  def validate
    unless report.accounted?
      messages[:error] << 'Report has not been accounted for'
    end
  end

  def process
    currency = Currency.first.id
    reimbursable_expenses_total = 0
    reimbursable_expenses_total = report.reimbursable_expenses_total.value if report.reimbursable_expenses_total.present?
    report.user.balance_sheet.subtract_approved_reports_total reimbursable_expenses_total, currency
    report.reimbursable_expenses_total.update(value: 0) if report.reimbursable_expenses_total.present?
    report.non_reimbursable_expenses_total.update(value: 0) if report.non_reimbursable_expenses_total.present?
    report.card_expenses_total.update(value: 0) if report.card_expenses_total.present?
    unless report.update_attributes(accounted: false)
      messages[:error] = report.errors.full_messages
      return
    end

    ######## Cash on Hand Addition ###############
    cash_on_hand_deduction = self.report.expenses.spent_from_cash_on_hand.joins_amount.sum(:value)
    if cash_on_hand_deduction.present? && cash_on_hand_deduction > 0
      payment_request = PaymentRequest.(self.report.user, nil, "CashOnHand", :credit, :advance_against_report_unapproval)
      payment_request.add_payment_item(PaymentRequest::PaymentItem.(self.report.user, self.report.user.cash_on_hand, cash_on_hand_deduction))
      op = AccountManager::Payments::PaymentProcessor.(self.report.user, payment_request: payment_request)
      if op.success?
        payment = op.payment_order.payments.first
        payment.update(reference_resource: self.report)
      end
    end
    ######### end of cash on hand addition ########
  end

  def post_process
    # mailer
  end

  def success
    report
  end

end