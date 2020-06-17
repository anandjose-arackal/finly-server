class ImportBudgetUrbanCompany

  def self.perform
    company = Company.find 220
    file_path = "/home/centos/finly_scripts/urban_company/uc_budgets_template_wo_amount_18_06_20.xlsx"
    admin = company.users.only_admins.first

    Saxlsx::Workbook.open file_path do |excel|
      excel.sheets.each do |sheet|
        # sheet = excel.sheets.first
        # first create the budget group which will be saved for each sheet
        budget_group_name = "#{sheet.name} Budget"
        budget_group = company.budget_groups.active.find_by(name: budget_group_name)
        # budget_group = BudgetGroup.new(name: budget_group_name,
        #                                company_id: company.id,
        #                                period_id: Period.id_for(:month),
        #                                start_date: Date.parse("01-05-2020").end_of_day,
        #                                end_date: Date.parse("30-04-2021").beginning_of_day,
        #                                budget_date_type_id: BudgetDateType.id_for(:entity_submitted_at),
        #                                created_by_user_id: admin.id,
        #                                payment: true,
        #                                purchase_order: true,
        #                                invoice: true,
        #                                purchase_request: true)
        # budget_group.save

        if budget_group.blank?
          puts "Budget group with name #{budget_group_name} not found!"
          next
        end

        sheet.rows.each_with_index do |row, index|
          # now each row has the list of items in an array, and it will
          # be used to create ONE budget_group_criteria object that will hold all budgets
          if index == 0
            next
          end
          # here we determine the name using the combination of departments, cost centers
          # locations and other criteria that constitute this budget
          length = row.size - 1
          amount = row[length]

          # puts "Length is #{length}"

          # next if amount == 0

          category_gl_codes = row[length - 3]
          if length > 7
            location_ids = row[length - 5].split(",").map(&:strip) rescue row[length - 5]
            cost_center_ids = row[length - 7]
            department_ids = row[length - 9]
          else
            location_ids = []
            cost_center_ids = []
            department_ids = row[length - 5]
          end
          puts "Department IDs: #{department_ids}"
          puts "Location IDs: #{location_ids}"
          puts "Cost center IDs: #{cost_center_ids}"
          puts "Category GL Codes: #{category_gl_codes}"

          locations = BranchLocation.with_id(location_ids)
          departments = Department.with_id(department_ids)
          cost_centers = CostCenter.with_id(cost_center_ids)
          categories = Category.where(gl_code: category_gl_codes)
          name = "(#{departments.pluck(:name).to_sentence}) "
          name += "| #{locations.pluck(:name).join(", ")} " if locations.present?
          name += "| #{cost_centers.pluck(:name).join(", ")} " if cost_centers.present?
          name += "| #{categories.pluck(:name).join(",")} " if categories.present?

          puts "Name is: #{name}"
          puts "Amount is #{amount}"

          # setting up the budget_group_criteria_mappings object here
          budget_group_criteria_mappings = []
          departments.each do |department|
            budget_group_criteria_mappings << {budgetable_type: "Department", budgetable_id: department.id}
          end
          locations.each do |location|
            budget_group_criteria_mappings << {budgetable_type: "BranchLocation", budgetable_id: location.id}
          end
          cost_centers.each do |cost_center|
            budget_group_criteria_mappings << {budgetable_type: "CostCenter", budgetable_id: cost_center.id}
          end
          categories.each do |category|
            budget_group_criteria_mappings << {budgetable_type: "Category", budgetable_id: category.id}
          end

          # now actually creating the budget group criteria
          criteria = budget_group.budget_group_criteria.build(name: name,
                                                              company_id: company.id,
                                                              created_by_user_id: admin.id,
                                                              budget_group_criteria_mappings_attributes: budget_group_criteria_mappings)
          puts criteria.valid?
          puts "--"
          criteria.save

          # now creating the related budgets for this criteria
          start_date = criteria.budget_group.start_date
          final_end_date = criteria.budget_group.end_date
          while start_date < final_end_date do
            end_date = BudgetManagerUtils.next_date(start_date, final_end_date, criteria.budget_group.period_id)
            break if end_date.blank?
            # if start_date.month == 5
            #   value = amount
            # else
            #   value = 0
            # end
            amount = 0
            budget = criteria.budgets.build(
                start_date: start_date.beginning_of_day,
                end_date: end_date.end_of_day,
                name: "#{start_date.strftime("%d %B, %Y")} - #{end_date.strftime("%d %B, %Y")}",
                company_id: criteria.company_id,
                budget_group_id: criteria.budget_group.id,
                user_id: criteria.budget_group.created_by_user_id,
                budget_date_type_id: criteria.budget_group.budget_date_type_id,
                calculated_before_tax_amount: criteria.budget_group.calculated_before_tax_amount,
                expense: budget_group.expense,
                purchase_order: budget_group.purchase_order,
                payment: budget_group.payment,
                invoice: budget_group.invoice,
                purchase_request: budget_group.purchase_request,
                budget_amount_attributes: {
                    value: value,
                    currency_id: 1
                }
            )

            budget.save
            puts "Budget from dates #{start_date} to #{end_date} with about #{amount} is #{budget.valid?}"

            # now setting the start date as the next day of the end date
            start_date = end_date + 1.day
          end
        end
      end
    end
  end
end