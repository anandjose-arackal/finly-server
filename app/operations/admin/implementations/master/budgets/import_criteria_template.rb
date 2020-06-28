class Admin::Implementations::Master::Budgets::ImportCriteriaTemplate < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'budgets.import_template'

  headers ({
      :id => "ID",
      :budget_group_id => "Budget Group ID",
      :budget_group_name => "Budget Group Name",
      :name => "Criteria Name",
      :department_id => "Department IDs",
      :category_id => "Category Code",
      :cost_center_id => "Cost Center IDs",
      :location_id => "Location IDs",
      :vendor_id => "Vendor IDs",
      :user_id => "User ID"
  })

  def valid_request
  end

  def input
    []
  end

  def post_process
  end


  # this method will have the other sheets that contain data about the
  # masters that are there in the system - like department, cost center,
  # location etc.
  def export(headers, contents)
    sheet_names =%w(
             BudgetGroupCriterium
             BudgetGroup
             Department
             Category
             CostCenter
             BranchLocation
             YesBankVendor
             User
             )
    file = Tempfile.new(['budget_criteria_import_template', '.xlsx'])
    workbook  = ::WriteXLSX.new(file)
    sheet_names.each_with_index do |sheet_name, index|

      # getting the records of each model

      records = sheet_name.constantize.where(company_id: company.id) rescue []
      contents = []

      worksheet = workbook.add_worksheet(sheet_name)

      if ["YesBankVendor", "User"].include?(sheet_name)
        vendor_user_headers.each_with_index do |header_name, header_index|
          worksheet.write(0, header_index, header_name)
        end
        records.each do |record|
          row = [record.id, record.name, record.email, record.mobile_number]
          contents << row
        end
      elsif ["BudgetGroupCriterium"].include?(sheet_name)
        self.headers.values.each_with_index do |header_name, header_index|
          worksheet.write(0, header_index, header_name)
        end
      else
        master_headers.each_with_index do |header_name, header_index|
          worksheet.write(0, header_index, header_name)
        end
        records.each do |record|
          row = [record.id, record.name, record.code]
          contents << row
        end
      end

      contents.each_with_index do |items, row|
        items.each_with_index do |item, column|
          worksheet.write(1 + row, column, item)
        end
      end
    end
    workbook.close
    file.rewind

    temp_file = TemporaryFile.create file: file, expires_on: (DateTime.now.beginning_of_day + 1.day)
    temp_file.file.url
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