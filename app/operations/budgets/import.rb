class Budgets::Import < Budgets::Base

  attr_accessor :file, :sheet, :header, :content, :result_hash, :company

  def init
    self.file = params[:file]
    self.sheet = ImportUtil.open_spreadsheet(self.file)
    self.company = user.company
  end

  def validate
    # validating presence of the name, start date, and end date
    (2..sheet.last_row).each do |i|
      row = sheet.row(i)
      # validating name
      if name_blank?(row)
        self.result_hash[i] = 1
        next
      end

      # checking if budget amount is present
      if amount_blank?(row)
        self.result_hash[i] = 2
        next
      end

      # checking if start date is present
      if start_date_blank?(row)
        self.result_hash[i] = 3
        next
      end

      # checking if end date is present
      if end_date_blank?(row)
        self.result_hash[i] = 4
        next
      end
    end

  end

  def process
    (2..sheet.last_row).each do |i|
      row = sheet.row(i)

      # checking for errors and skipping that particular line if there is
      if result_hash[i].present?
        case result_hash[i]
          when 1
            result_hash[i] = "Name of the budget cannot be blank"
          when 2
            result_hash[i] = "Budget amount cannot be blank"
          when 3
            result_hash[i] = "Start date the budget cannot be blank"
          when 4
            result_hash[i] = "Name of the budget cannot be blank"
          else
            # nothing to do here
        end
      end

      budget_name = row[import_fields[:budget_name]]
      budget_amount = row[import_fields[:amount]]
      parent_budget_name = row[import_fields[:parent_budget_name]]
      start_date = row[import_fields[:start_date]]
      end_date = row[import_fields[:end_date]]
      categories_budgetable = row[import_fields[:categories_budgetable]].split(",")
      departments_budgetable = row[import_fields[:departments_budgetable]].split(",")
      locations_budgetable = row[import_fields[:locations_budgetable]].split(",")
      vendors_budgetable = row[import_fields[:vendors_budgetable]].split(",")
      users_budgetable = row[iport_fields[:users_budgetable]].split(",")
      expense = row[import_fields[:expense_y_n]]
      payment = row[import_fields[:payment_y_n]]
      purchase_order = row[import_fields[:purchase_order_y_n]]

      budget_criteria_mappings = []
      categories = company.categories.with_id(categories_budgetable)
      categories.each do |category|
        budget_criteria_mappings << {budgetable_id: category.id, budgetable_type: "Category"}
      end

      departments = company.departments.with_id(departments_budgetable)
      departments.each do |department|
        budget_criteria_mappings << {budgetable_id: department.id, budgetable_type: "Department"}
      end

      locations = company.locations.with_id(locations_budgetable)
      locations.each do |location|
        budget_criteria_mappings << {budgetable_id: location.id, budgetable_type: "BranchLocation"}
      end

      vendors = company.yes_bank_vendors.with_id(vendors_budgetable)
      vendors.each do |vendor|
        budget_criteria_mappings << {budgetable_id: vendor.id, budgetable_type: "YesBankVendor"}
      end

      users = company.users.with_id(users_budgetable)
      users.each do |user|
        budget_criteria_mappings << {budgetable_id: user.id, budgetable_type: "User"}
      end

      parent_budget = company.budgets.find_by(name: parent_budget_name)

      budget = company.budgets.build(name: budget_name, start_date: start_date, end_date: end_date,
                                     expense: expense, payment: payment, purchase_order: purchase_order,
                                     parent_id: parent_budget.id,
                                     amounts_attributes: {value: budget_amount, currency_id: 1},
                                     budget_criteria_mappings_attributes: budget_criteria_mappings)

      if budget.save
        result_hash[i] = "Budget successfully created"
      else
        result_hash[i] = budget.errors.full_messages.to_sentence
      end

    end
  end

  def post_process
    self.header = [
        "Budget Name",
        "Amount",
        "Parent Budget Name",
        "Start Date (dd-mm-yyyy)",
        "End Date (dd-mm-yyyy)",
        "Categories Budgetable ",
        "Departments Budgetable",
        "Locations Budgetable",
        "Vendors Budgetable",
        "Expense? (Y/N)",
        "Payment? (Y/N)",
        "Purchase Order? (Y/N)"
    ]
    self.header << "Result"
    self.content = []
    (2..sheet.last_row).each do |i|
      self.content << sheet.row(i)
      self.content[i-2] << self.result_hash[i]
    end
  end

  def success
    self.response = Exporter.new(user, {spreadsheet: {headers: self.headers, contents: self.content}}, messages)
  end

  private

  def import_fields
    [
        :budget_name => 0,
        :amount => 1,
        :parent_budget_name => 2,
        :start_date => 3,
        :end_date => 4,
        :categories_budgetable => 5,
        :departments_budgetable => 6,
        :locations_budgetable => 7,
        :vendors_budgetable => 8,
        :users_budgetable => 9,
        :expense_y_n => 10,
        :payment_y_n => 11,
        :purchase_order_y_n => 12
    ]
  end

  def name_blank?(row)
    if row[import_fields[:budget_name]].blank?
      return true
    end
    false
  end

  def amount_blank?(row)
    if row[import_fields[:amount]].blank?
      return true
    end
    false
  end

  def start_date_blank?(row)
    if row[import_fields[:start_date]].blank?
      return true
    end
    false
  end

  def end_date_blank?(row)
    if row[import_fields[:end_date]].blank?
      return true
    end
    false
  end

end