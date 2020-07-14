class Admin::Implementations::Master::Budgets::ExportCriteria < Admin::Implementations::Processor::Export


  bus Admin::Implementations::Master::BaseMaster
  subscribe 'budgets.export'

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

  def valid_request

  end

  def input

  end

  # here I need to populate the contents collection with the
  # data that I am looking tp export
  def process
    export(self.headers.values, contents)
  end

  def id(bgc)
    bgc.id
  end

  def budget_group_id(bgc)
    bgc.budget_group_id
  end

  def budget_group_name(bgc)
    bgc.budget_group&.name
  end

  def name(bgc)
    bgc.name
  end

  def department_id(bgc)
    bgc.budgetable_departments.pluck(:id).join(",")
  end

  def category_id(bgc)
    bgc.budgetable_categories.pluck(:id).join(",")
  end

  def cost_center_id(bgc)
    bgc.budgetable_cost_centers.pluck(:id).join(",")
  end

  def location_id(bgc)
    bgc.budgetable_locations.pluck(:id).join(",")
  end

  def vendor_id(bgc)
    bgc.budgetable_vendors.pluck(:id).join(",")
  end

  def user_id(bgc)
    bgc.budgetable_users.pluck(:id).join(",")
  end

  def destroy(bgc)
    ""
  end

  def post_process

  end

  # This sheet will contain the contents of each sheet, stored with the key of
  # each respective sheet name
  def contents
    contents = {}

    sheet_names = %w(
       BudgetGroupCriterium
       BudgetGroup
       Department
       Category
       CostCenter
       BranchLocation
       YesBankVendor
       User
    )

    sheet_names.each do |sheet_name|
      contents[sheet_name] = []

      # records will contain all the records of the specific entity that we're looking
      # to loop through and fill inside the sheet that contains the exported data
      records = sheet_name.constantize.where(company_id: company.id) rescue []

      records.each do |record|
        row = []
        if ["YesBankVendor", "User"].include?(sheet_name)
          row = [record.id, record.name, record.email, record.mobile_number]
        # if this is the header, it should contain all the details of the budget
        # group criteria that are a part of the budget groups in the company
        elsif ["BudgetGroupCriterium"].include?(sheet_name)
          self.headers.keys.each do |field|
            row << self.send(field, record)
          end
        else
          row = [record.id, record.name, record.code]
        end

        contents[sheet_name] << row
        item_complete true
      end
    end
    contents
  end


  ##################################### EXPORT OVERRIDE ###################################
  # this method is also being overriden to allow for the special case of criteria xport
  def export(headers, contents)
    file = Tempfile.new(['budget_import_template', '.xlsx'])
    workbook  = ::WriteXLSX.new(file)
    contents.each  do |sheet_name, sheet_contents|
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
  ##########################################################################################



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