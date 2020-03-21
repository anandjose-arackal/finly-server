# this operation will return a list of the applicable budgets of a particular document
# i.e. if we are looking at a particular document - this operation will return all the
# budgets that apply to this document along with the consumption data for each of them
class BudgetManager::BudgetsCalculator::ApplicableBudgets < BudgetManager::BudgetsCalculator::Base

  attr_accessor :departments, :cost_centers, :categories, :locations, :vendors, :users,
                :company, :applicable_budget_group_criteria, :document

  # this step just finds the documents and intitializes the various parameters
  # i.e. departments, cost centers, etc.
  step :init!

  # this step will retrieve all the budgets that apply to this particular document
  # based on the initialized departments, cost centers etc.
  step :criteria_based_budgets!

  # the below step will further scope down the budget that will apply to a particular
  # document based on the date - i.e. a budget group criterium will have a bunch of
  # budgets among which only some of them will apply
  step :date_based_budgets!

  def init!(options, document:, **)
    self.document = document
    self.company = document.company
    case document.class.name
    when "PurchaseOrder", "Invoice"
      # in this case users will not be there because there's no such thing as
      # a user consuming a PO, it is always with respect to the other criteria
      self.departments = Department.with_id(document.items.pluck(:department_id).compact)
      self.cost_centers = CostCenter.with_id(document.items.pluck(:cost_center_id).compact)
      self.vendors = [document.vendor].compact
      self.locations = [document.location].compact
      self.categories = Category.with_id(document.items.pluck(:category_id).compact)
      self.users = []
    when "PurchaseRequest"
      self.departments = Department.with_id(document.items.pluck(:department_id).compact)
      self.cost_centers = CostCenter.with_id(document.items.pluck(:cost_center_id).compact)
      self.vendors = []
      self.locations = [document.location].compact
      self.categories = Category.with_id(document.items.pluck(:category_id).compact)
      self.users = []
    when "BankPaymentRequest", "PaymentOrder"
      # here we'll extract the categories as well from the invoice / purchase order
      # that is linked to each respective payment in the payment order
      case document.payments.first&.parent_type
      when "PurchaseOrder"
        self.categories = Category.with_id(PurchaseOrderItem.with_purchase_order_id(document.payments.pluck(:parent_id)).pluck(:category_id))
      when "Invoice"
        self.categories = Category.with_id(InvoiceLineItem.with_parent_id(document.payments.pluck(:parent_id)).pluck(:category_id))
      else
        self.categories = []
      end
      self.departments = Department.with_id(document.payments.pluck(:department_id).compact)
      self.cost_centers = CostCenter.with_id(document.payments.pluck(:cost_center_id).compact)
      self.vendors = YesBankVendor.with_id(document.payments.map { |payment| payment.receiving_user_id if payment.receiving_user.is_a?(YesBankVendor)})
      self.locations = BranchLocation.with_id(document.payments.pluck(:location_id).compact)
      self.categories += Category.with_id(document.payments.pluck(:category_id).compact)
      self.users = []
    when "Report", "Expense"
      self.departments = [document.department].compact
      self.cost_centers = [document.cost_center].compact
      # here vendors doesn't make sense because expenses don't have a vendor per se
      self.vendors = []
      self.categories = Category.with_id(document.expenses.pluck(:category_id).compact)
      # here users will be the owner of the report as all expenses are incurred by them
      self.users = [document.user].compact
      self.locations = []
    else
      raise "Invalid Document Type passed to ApplicableBudgets Class"
    end
    true
  end


  # this method will extract the budget group criteria that are relevant to the extracted criteria in the
  # above init step
  def criteria_based_budgets!(options, **)
    budget_criteria = self.company.budget_group_criteria
    criteria_mappings = BudgetGroupCriteriaMapping.with_budget_group_criteria_id(budget_criteria.pluck(:id))
    # first extract all criteria mappings that apply to this particular combination of departments, locations, cost centers etc
    applicable_criteria_mappings = criteria_mappings.where("(budgetable_type = ? AND budgetable_id IN (?))
                                                              OR (budgetable_type = ? AND budgetable_id IN (?))
                                                              OR (budgetable_type = ? AND budgetable_id IN (?))
                                                              OR (budgetable_type = ? AND budgetable_id IN (?))
                                                              OR (budgetable_type = ? AND budgetable_id IN (?))
                                                              OR (budgetable_type = ? AND budgetable_id IN (?))",
                                                              "Department", self.departments.pluck(:id),
                                                              "Location", self.locations.pluck(:id),
                                                              "CostCenter", self.cost_centers.pluck(:id),
                                                              "YesBankVendor", self.vendors.pluck(:id),
                                                              "User", self.users.pluck(:id),
                                                              "Category", self.categories.pluck(:id))


    # applicable_criteria_mapping_ids = criteria_mappings.with_budgetable_type("Department").with_budgetable_id(self.departments.pluck(:id)).pluck(:id)
    # applicable_criteria_mapping_ids += criteria_mappings.with_budgetable_type("CostCenter").with_budgetable_id(self.cost_centers.pluck(:id)).pluck(:id)
    # applicable_criteria_mapping_ids += criteria_mappings.with_budgetable_type("Location").with_budgetable_id(self.locations.pluck(:id)).pluck(:id)
    # applicable_criteria_mapping_ids += criteria_mappings.with_budgetable_type("Category").with_budgetable_id(self.categories.pluck(:id)).pluck(:id)
    # applicable_criteria_mapping_ids += criteria_mappings.with_budgetable_type("YesBankVendor").with_budgetable_id(self.vendors.pluck(:id)).pluck(:id)
    # applicable_criteria_mapping_ids += criteria_mappings.with_budgetable_type("User").with_budgetable_id(self.users.pluck(:id)).pluck(:id)


    self.applicable_budget_group_criteria = BudgetGroupCriterium.with_id(applicable_criteria_mappings.pluck(:budget_group_criterium_id))
    true
  end

  # these are the budgets that will finally be applied to this particular document
  # which will be decided based on the date of the respective document
  def date_based_budgets!(options, **)
    budget_ids = []
    # we have to cycle through each budget group criteria that has been selected,
    # and based on the budget_date_type need to decide on which budgets to include
    budgets = Budget.with_budget_criteria_id(self.applicable_budget_group_criteria.pluck(:id))
    budgets.each do |budget|
      date_type_id = budget.budget_date_type_id
      dates = get_dates_from_document(document, date_type_id)
      dates.each do |date|
        budget_ids << budget.id if budget.within_timeframe?(date)
      end
    end
    budgets = Budget.with_id(budget_ids)
    result = {
        budgets: budgets
    }
    options["result"] = result
  end



  def get_dates_from_document(document, date_type_id)
    dates = []
    case self.document.class.name
    when "PurchaseOrder", "PurchaseRequest"
      case date_type_id
      when BudgetDateType.id_for(:entity_date), BudgetDateType.id_for(:entity_created_at)
        dates << document.created_at.to_date
      when BudgetDateType.id_for(:entity_submitted_at)
        dates << (document.submitted_at&.to_date || document.created_at.to_date)
      else
        dates << document.created_at.to_date
      end
    when "Report"
      case date_type_id
      when BudgetDateType.id_for(:entity_date)
        dates += document.expenses.pluck(:entity_date).uniq.compact
      when BudgetDateType.id_for(:entity_created_at)
        dates += document.expenses.pluck(:created_at).map(&:to_date)
      when BudgetDateType.id_for(:entity_submitted_at)
        dates << (document.submitted_at&.to_date || document.created_at.to_date)
      else
        dates << document.created_at.to_date
      end
    when "Invoice"
      case date_type_id
      when BudgetDateType.id_for(:entity_date)
        dates << document.date
      when BudgetDateType.id_for(:entity_created_at)
        dates << document.created_at.to_date
      when BudgetDateType.id_for(:entity_submitted_at)
        dates << (document.submitted_at&.to_date || document.created_at.to_date)
      else
        dates << document.created_at.to_date
      end
    when "BankPaymentRequest"
      case date_type_id
      when BudgetDateType.id_for(:entity_date)
        dates += document.payments.pluck(:date)
      when BudgetDateType.id_for(:entity_created_at)
        dates << document.created_at&.to_date
      when BudgetDateType.id_for(:entity_submitted_at)
        dates << (document.submitted_at&.to_date || document.created_at.to_date)
      else
        dates << document.created_at.to_date
      end
    end

    return dates.compact
  end

end