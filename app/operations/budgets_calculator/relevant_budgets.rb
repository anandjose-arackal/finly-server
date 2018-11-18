# this operation takes a particular object and returns all budgets that apply to this particular
# object and require calculation
class BudgetsCalculator::RelevantBudgets < BudgetsCalculator::Base

  attr_accessor :relevant_budgets, :object

  class BudgetsCalculator::RelevantBudgets::RelevantBudgetsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :relevant_budgets, :budget_data, :object

    def init
      self.relevant_budgets = params[:relevant_budgets]
      self.object = params[:object]
      # now extract the details of all budgets
      self.budget_data = []
      self.relevant_budgets.each do |budget|
        processor_instance = BudgetsCalculator::Calculate::BudgetsProcessor.new(budget)
        budget_spent_amount = processor_instance.spent_amount
        expenses, payments, purchase_order_items, invoice_items = processor_instance.spent_entities
        # now in each spent amount, we need to add this object's amount so that
        # it shows in the front end that the budget amount has been exceeded

        case self.object.class.name
          when "PurchaseOrder"
            if self.object.open? || self.object.retracted? || self.object.rejected? || self.object.voided?
              po_line_items = processor_instance.relevant_items(self.object)
              if po_line_items.present?
                current_object_amount = po_line_items.joins(:total_amount).sum(:value)
                spent_amount = budget_spent_amount + current_object_amount
              else
                spent_amount = budget_spent_amount
              end
            else
              spent_amount = budget_spent_amount
            end
          when "Invoice"
            if self.object.open? || self.object.rejected? || self.object.retracted?
              invoice_line_items = processor_instance.relevant_items(self.object)
              if invoice_line_items.present?
                current_object_amount = invoice_line_items.joins(:net_amount).sum(:value)
                spent_amount = budget_spent_amount + current_object_amount
              else
                spent_amount = budget_spent_amount
              end
            else
              spent_amount = budget_spent_amount
            end
          when "PaymentOrder", "BankPaymentRequest"
            payments = processor_instance.relevant_items(self.object)
            if payments.present?
              current_object_amount = payments.joins(:amount).sum(:value)
              spent_amount = budget_spent_amount + current_object_amount
            else
              spent_amount = budget_spent_amount
            end
          when "Report"
            expenses = processor_instance.relevant_items(self.object)
            if expenses.present?
              current_object_amount = expenses.joins(:amount).sum(:value)
              spent_amount = budget_spent_amount + current_object_amount
            else
              spent_amount = budget_spent_amount
            end
          else
            spent_amount = 0
        end
        self.budget_data << {
            budget: budget,
            spent_amount: spent_amount,
            spent_entities: {
            expenses: expenses,
            payments: payments,
            purchase_order_items: purchase_order_items,
            invoice_items: invoice_items
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
        delivery_date = (self.object.is_a?(PurchaseOrder)) ? self.object.created_at : self.object.date
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
        payments = self.object.payments
        category_ids = payments.pluck(:category_id)
        department_ids = payments.pluck(:department_id)
        location_ids = payments.pluck(:location_id)
        vendor_ids = payments.where(receiving_user_type: "YesBankVendor").pluck(:receiving_user_id)
        self.relevant_budgets = company_budgets.with_budgetable_departments(department_ids).with_budgetable_categories(category_ids).with_budgetable_locations(location_ids).with_budgetable_vendors(vendor_ids)
      else
        self.relevant_budgets = []
    end
  end

  def success
    params[:relevant_budgets] = self.relevant_budgets
    BudgetsCalculator::RelevantBudgets::RelevantBudgetsPresenter.new(user, params, messages)
  end
end