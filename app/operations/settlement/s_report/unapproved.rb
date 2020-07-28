# action that recomputes settlement once a report is unapproved
# user passed must be report owner and NOT report person unapproving it
# params:
# report_id: id of the report that is being unapproved


class Settlement::SReport::Unapproved < Reports::Base
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

    # perform the below COH addition only if there was a corresponding debit of the COH from this particular report
    # What this does is ensure that only if a report had its COH deducted should we consider deducing COH
    reference_payment = self.report.reference_payment
    if reference_payment.present? && reference_payment.debit? && reference_payment.payment_purpose_id == PaymentPurpose.id_for(:settlement_against_advance)

      ######## Cash on Hand Addition ###############

      user_pocket_ids = report.expenses.pluck(:spent_from_id).uniq
      cash_pockets = report.user.user_pockets.cash_pockets_only.with_id(user_pocket_ids)
      cash_pockets.each do |pocket|
        deduction = self.report.expenses.with_spent_from_id(pocket.id).joins(:amount).sum(pocket.base_currency&.country_code)
        if deduction.present? && deduction > 0
          payment_request = PaymentRequest.(self.report.user, nil, "UserPocket", :credit, :advance_against_report_unapproval)
          payment_request.add_payment_item(PaymentRequest::PaymentItem.(self.report.user, pocket, deduction))
          op = AccountManager::Payments::PaymentProcessor.(self.report.user, payment_request: payment_request)
          if op.success?
            payment = op.payment_order.payments.first
            # updating the reference payment of the report to the payment in question
            self.report.update(reference_payment_id: payment.id)
            payment.update(reference_resource_type: self.report.class.name)
            # payment.update(reference_resource: self.report)
          else
            # this will send an email to us telling us that COH deduction failed for this user
            Event::EAlert::Create.(nil, {
                title: 'COH addition on report unapproval failed',
                description: "Addition to COH for unapproval of report ID: #{self.report.id} failed because: #{op.messages[:error]}",
                subject: "Addition to COH for unapproval of report ID: #{self.report.id} failed because: #{op.messages[:error]}"
            })
          end
        end
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