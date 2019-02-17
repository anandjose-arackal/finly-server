# action that recomputes settlement once a money_request is unapproved
# user passed must be money_request owner and NOT money_request person unapproving it
# params:
# money_request_id: id of the money_request that is being unapproved


class Settlement::SMoneyRequests::Unapproved < MoneyRequests::Base
  attr_accessor :money_request

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or params passed."
    end
  end

  def init
    self.money_request = params[:money_request]
  end

  def validate
    unless money_request.accounted?
      messages[:error] << 'MoneyRequest has not been accounted for'
    end
  end

  def process
    currency = Currency.first.id
    reimbursable_expenses_total = 0
    reimbursable_expenses_total = money_request.reimbursable_expenses_total.value if money_request.reimbursable_expenses_total.present?
    money_request.user.balance_sheet.subtract_approved_money_requests_total reimbursable_expenses_total, currency
    money_request.reimbursable_expenses_total.update(value: 0) if money_request.reimbursable_expenses_total.present?
    money_request.non_reimbursable_expenses_total.update(value: 0) if money_request.non_reimbursable_expenses_total.present?
    money_request.card_expenses_total.update(value: 0) if money_request.card_expenses_total.present?
    unless money_request.update_attributes(accounted: false)
      messages[:error] = money_request.errors.full_messages
    end

    ######## Cash on Hand Addition ###############
    cash_on_hand_deduction = self.money_request.expenses.spent_from_cash_on_hand.joins_amount.sum(:value)
    if cash_on_hand_deduction.present? && cash_on_hand_deduction > 0
      payment_request = PaymentRequest.(self.money_request.user, nil, "CashOnHand", :credit, :advance_against_money_request_unapproval)
      payment_request.add_payment_item(PaymentRequest::PaymentItem.(self.money_request.user, self.money_request.user.cash_on_hand, cash_on_hand_deduction))
      op = AccountManager::Payments::PaymentProcessor.(self.money_request.user, payment_request: payment_request)
      if op.success?
        payment = op.payment_order.payments.first
        payment.update(reference_resource: self.money_request)
      end
    end
    ######### end of cash on hand addition ########
  end

  def post_process
    # mailer
  end

  def success
    money_request
  end

end