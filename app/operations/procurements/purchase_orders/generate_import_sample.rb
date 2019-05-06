class Procurements::PurchaseOrders::GenerateImportSample < Procurements::PurchaseOrders::Base

  attr_accessor :company, :sample_type, :headers, :content, :sheets

  def init
    self.company = user.company
  end

  def process
    self.headers = default_headers
    self.content = []
    self.sheets = [
        {
            item_headers: self.headers,
            item_contents: []
        }
    ]
    # adding Item to excel sheet
    item_headers = ["Item Number", "Description", "Rate", "HSN/SAC", "Item Code", "Default Category Name", "Default Category ID"]
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
    user.company.cost_centers.vendor_payments_only.each do |cost_center|
      cost_center_contents << [cost_center.id, cost_center.name]
    end
    self.sheets << {
        item_headers: cost_center_headers,
        item_contents: cost_center_contents,
        name: "Cost Centers"
    }

    category_headers = ["ID", "Category Name"]
    category_contents = []
    user.company.categories&.inward_invoice_items_only.each do |category|
      category_contents << [category.id, category.name]
    end
    self.sheets << {
      item_headers: category_headers,
      item_contents: category_contents,
      name: "Categories"
    }

  end

  def success
    # params[:result_file_path] = temp_file.file.url
    # Procurements::PurchaseOrders::GenerateImportSample::GeneratePresenter.new(user, params, messages)
    Exporter.new(user, {xlsx: {headers: self.headers, contents: self.content, sheets: self.sheets}, expire_file_duration: 1.day}, messages)
  end

  # class Procurements::PurchaseOrders::GenerateImportSample::GeneratePresenter < BaseOperation::BasePresenter::SuccessPresenter
  #   attr_accessor :result_file_path

  #   def init
  #     self.result_file_path = params[:result_file_path]
  #   end
  # end

  private

  def default_headers
    [
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
     "Tax",
     "Total"
    ]
  end

end