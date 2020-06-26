class Admin::Implementations::Master::Budgets::ImportCriteria < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'budgets.import'

  headers({
              :id => "ID",
              :budget_group_id => "Budget Group ID",
              :budget_group_name => "Budget Group Name",
              :name => "Criteria Name",
              :department_id => "Department IDs",
              :category_id => "Category Code",
              :cost_center_id => "Cost Center IDs",
              :location_id => "Location IDs",
              :vendor_id => "Vendor IDs",
              :user_id => "User ID",
              :destroy => "Destroy (Y/N)"
          })

  def process
    path = Rails.env.production? ? self.implementation_request.request_file&.url : self.implementation_request.request_file&.path
    self.input = Roo::Spreadsheet.open(path)

    output = {}

    self.input.each_with_pagename do |name, sheet|

      output[name] = []

      if name == "BudgetGroupCriterium"
        # i.e. process the rows only if it's the Budget Group Criterium sheet
        (2..sheet.last_row).each do |index|
          row = sheet.row(index)
          result = process_row(row)
          if result.success?
            item_complete true
          else
            item_complete false
          end
          row << result.message
          output[name] << row
        end
      else
        (1..sheet.last_row).each do |index|
          row = sheet.row(index)
          output[name] << row
        end
      end

    end

    export(headers, output)
  end

  def export(headers, contents)
    file = Tempfile.new(['budget_import_result', '.xlsx'])
    workbook  = ::WriteXLSX.new(file)
    contents.each do |sheet_name, sheet_contents|
      worksheet = workbook.add_worksheet(sheet_name)

      # First add all the headers based on the type of sheet that is being geenerated
      if ["YesBankVendor", "User"].include?(sheet_name)
        vendor_user_headers.each_with_index do |name, index|
          worksheet.write(0, index, name)
        end
      elsif ["BudgetGroupCriterium"].include?(sheet_name)
        self.headers.values.each_with_index do |header_name, header_index|
          worksheet.write(0, header_index, header_name)
        end
      else
        master_headers.each_with_index do |header_name, header_index|
          worksheet.write(0, header_index, header_name)
        end
      end


      # Now we can add all the contents that are required to be added for the
      # sheet from the contents collection
      sheet_contents.each_with_index do |items, row|
        items.each_with_index do |item, column|
          worksheet.write(1 + row, column, item)
        end
      end
    end
    workbook.close
    file.rewind
    self.implementation_request.result_file = file
    self.implementation_request.save
    progress_update(:completed)
  end

  def process_row(data)
    # here unless we're going to be destroying this row of records, we need to set up the
    # data to create the budget group criterium and then create or update it based on
    # the requirement

    id = data[0]
    name = data[2]
    budget_group_id = data[1]
    departments = Department.where(id: data[3].split(",")) rescue []
    categories = Category.where(id: data[4].split(",")) rescue []
    cost_centers = CostCenter.where(id: data[5].split(",")) rescue []
    locations = BranchLocation.where(id: data[6].split(",")) rescue []
    vendors = YesBankVendor.where(id: data[7].split(",")) rescue []
    users = User.where(id: data[8].split(",")) rescue []


    budget_group = company.budget_groups.find_by(id: budget_group_id)
    if budget_group.blank?
      return result fail, "Could not find budget group criterium"
    end

    # setting up the various mappings of the budget criteria so that it can be
    # built to create the budget group criteria that we want
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
    vendors.each do |vendor|
      budget_group_criteria_mappings << {budgetable_type: "YesBankVendor", budgetable_id: vendor.id}
    end
    users.each do |user|
      budget_group_criteria_mappings << {budgetable_type: "User", budgetable_id: user.id}
    end

    criteria = budget_group.budget_group_criteria.find_by(id: id)
    if criteria.present?
      criteria = budget_group.budget_group_criteria.assign_attributes(name: name,
                                                          company_id: company.id,
                                                          created_by_user_id: user.id,
                                                          budget_group_criteria_mappings_attributes: budget_group_criteria_mappings)
      update_row(criteria)
    else
      criteria = budget_group.budget_group_criteria.build(name: name,
                                                          company_id: company.id,
                                                          created_by_user_id: user.id,
                                                          budget_group_criteria_mappings_attributes: budget_group_criteria_mappings)
      create_row(criteria)
    end



  end

  def crete_row(criteria)
    if criteria.save
      return result true, "Criteria created!"
    else
      return result false, criteria.errors.full_messages.to_sentence
    end
  end


  def update_row(criteria)
    if criteria.save
      return result true, "Criteria created!"
    else
      return result false, criteria.errors.full_messages.to_sentence
    end
  end


  def master_headers
    [
        "ID",
        "Name",
        "Code"
    ]
  end

  def vendor_user_headers
    [
        "ID",
        "Name",
        "Email",
        "Mobile Number"
    ]
  end
end