class Procurements::Invoices::Templates::GenerateImportSample < Procurements::Invoices::Templates::Base

  attr_accessor :company, :sample_type, :headers, :content, :sheets

  def init
    self.company = user.company
    self.content = params[:content] || []
  end

  def process
    self.headers = default_headers
    # self.content = []
    self.sheets = [
        {
            item_headers: self.headers,
            item_contents: self.content
        }
    ]
    # adding Item to excel sheet
    item_headers = ["Item Number", "Description", "Rate", "HSN/SAC", "Item Code", "Default Category Name", "Default Category ID", "Default Tax Rate"]
    item_contents = []
    company.items.where(active: true).includes(:category).each do |item|
      item_contents << [item.item_number, item.description, item.rate, item.hsn_sac, item.item_code, item.category&.name, item.category_id]
    end
    self.sheets << {
        item_headers: item_headers,
        item_contents: item_contents,
        name: "Inventory Items"
    }

    # adding departments to the excel sheet
    department_headers = ["ID", "Department Name"]
    department_contents = []
    departments = Company::Departments::Index.(user, params)
    # current_company.departments.each do |department|
    if departments.policy_department_filter_mapping.present?
      departments.policy_department_filter_mapping.each do |department|
        department_contents << [department.id, department.name]
      end
    end
    self.sheets << {
        item_headers: department_headers,
        item_contents: department_contents,
        name: "Departments"
    }

    # adding Cost Centers to the excel sheet
    cost_center_headers = ["ID", "Cost Center Name"]
    cost_center_contents = []
    current_company.cost_centers.vendor_payments_only.each do |cost_center|
      cost_center_contents << [cost_center.id, cost_center.name]
    end
    self.sheets << {
        item_headers: cost_center_headers,
        item_contents: cost_center_contents,
        name: "Cost Centers"
    }

    category_headers = ["ID", "Category Name"]
    category_contents = []
    current_company.categories&.inward_invoice_items_only.each do |category|
      category_contents << [category.id, category.name]
    end
    self.sheets << {
      item_headers: category_headers,
      item_contents: category_contents,
      name: "Categories"
    }

    # Tax Rates List
    tax_rates_header = ["ID", "Tax Rate Name", "Tax %", "Internal ID"]
    tax_rates_content = []

    user.company.tax_rates.non_deleted.each do |tax_rate|
      tax_rates_content << [tax_rate.id, tax_rate.name, tax_rate.rate, tax_rate.internal_id]
    end

    self.sheets << {
      item_headers: tax_rates_header,
      item_contents: tax_rates_content,
      name: "Tax Rates"
    }
  end

  def success
    # self.response = Exporter.new(user, {spreadsheet: {headers: self.headers, contents: self.content, sheets: self.sheets}}, messages)
    Exporter.new(user, {xlsx: {headers: self.headers, contents: self.content, sheets: self.sheets}, expire_file_duration: 1.day}, messages)
  end

  private

  def default_headers
    headers = [
      "Description",
      "Item number",
      "Department ID",
      "Cost Center ID",
      "Comment",
      "Item code",
      "Category ID",
      "HSN/SAC",
      "Quantity",
      "Unit of measurement",
      "Rate",
      "Discount",
      "Tax Rate ID",
      "Total"
    ]
    if self.content.present?
      headers.push "System Messages"
    end
    headers
    
  end

end
