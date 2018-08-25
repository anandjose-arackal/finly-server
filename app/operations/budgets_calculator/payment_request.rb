class BudgetsProcessor::PaymentRequest < BudgetsProcessor::Base
  attr_accessor :payment_request
  def init
    super
    self.payment_request = params[:payment_request]

    # It shouldn't show user related budgets
    # self.budgets += Budget.with_budgetable_user_id(self.payment_request.owner_id)

    payments = self.payment_request.payment_order.payments

    yes_bank_vendor_ids = payments.vendor_payments_only.pluck(:receiving_user_id)
    category_ids = payments.pluck(:category_id)

    invoices = Invoice.with_id(payments.pluck(:invoice_id))

    cost_center_ids = invoices.pluck(:cost_center_id)



    # Find budgets associated with vendors
    self.budgets += Budget.with_budgetable_yes_bank_vendor_id(yes_bank_vendor_ids)

    # Find budgets associated with categories
    self.budgets += Budget.with_budgetable_category_id(category_ids)

    # Find budgets associated with cost_centers
    self.budgets += Budget.with_budgetable_cost_center_id(cost_center_ids)

    cf_budgets = []
    budget_ids = []
    payments.each do |payment|
      next if payment.invoice.blank?
      payment.invoice&.custom_fields&.only_drop_downs&.each do |cf|
        field_drop_down_item_id = cf.value.value_id
        if budget_ids.include?(field_drop_down_item_id)
          next
        end

        budget_ids.push(field_drop_down_item_id)
        budgets = Budget.with_budgetable_field_drop_down_item(field_drop_down_item_id)
        cf_budgets += budgets
      end
    end

    self.budgets += cf_budgets.uniq
  end
end