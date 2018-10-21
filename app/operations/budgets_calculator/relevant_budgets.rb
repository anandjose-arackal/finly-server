# this operation takes a particular object and returns all budgets that apply to this particular
# object and require calculation
class BudgetsCalculator::RelevantBudgets < BudgetsCalculator::Base

  attr_accessor :relevant_budgets, :object

  class BudgetsCalculator::RelevantBudgets::RelevantBudgetsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :relevant_budgets, :budget_data

    def init
      self.relevant_budgets = params[:relevant_budgets]
      # now extract the details of all budgets
      self.budget_data = []
      self.relevant_budgets.each do |budget|
        processor_instance = BudgetsCalculator::Calculate::BudgetsProcessor.new(budget)
        spent_amount = processor_instance.spent_amount
        expenses, payments, purchase_order_items = processor_instance.spent_entities
        self.budget_data << {
            budget: budget,
            spent_amount: spent_amount,
            spent_entities: {
            expenses: expenses,
            payments: payments,
            purchase_order_items: purchase_order_items
        }}
      end
    end
  end

  def init
    self.object = params[:object]
  end

  def validate
    if self.object.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def process
    company_budgets = user.company.budgets
    case self.object.class.name
      when "PurchaseOrder", "Invoice"
        delivery_date = (self.object.is_a?(PurchaseOrder)) ? self.object.delivery_date : self.object.date
        relevant_budgets = company_budgets.applicable_to_purchase_orders.contains_date(delivery_date)
        relevant_budget_ids = []
        # relevant_budget_ids += relevant_budgets.with_budgetable_locations(self.object.location_id).pluck(:id)
        department_ids = [self.object.department_id, self.object.sub_department_id]
        relevant_budget_ids = relevant_budgets.with_budgetable_departments(department_ids).pluck(:id)
        # relevant_budget_ids = relevant_budgets.with_budgetable_vendors(self.object.vendor_id).pluck(:id)
        inventory_item_ids = self.object.items.pluck(:inventory_line_item_id)
        category_ids = InventoryLineItem.with_id(inventory_item_ids).pluck(:category_id)
        relevant_budget_ids = relevant_budgets.with_id(relevant_budget_ids).with_budgetable_categories(category_ids).pluck(:id)
        self.relevant_budgets = company_budgets.with_id(relevant_budget_ids)
      when "Expense", "Report"
        self.relevant_budgets = user.company.budgets.applicable_to_expenses
      when "Payment", "PaymentOrder", "BankPaymentRequest"
        self.relevant_budgets = user.company.budgets.applicable_to_payments
      else
        self.relevant_budgets = []
    end
  end

  def success
    params[:relevant_budgets] = self.relevant_budgets
    BudgetsCalculator::RelevantBudgets::RelevantBudgetsPresenter.new(user, params, messages)
  end
end