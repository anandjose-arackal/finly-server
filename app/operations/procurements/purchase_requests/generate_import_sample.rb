class Procurements::PurchaseRequests::GenerateImportSample < Procurements::PurchaseRequests::Base

  attr_accessor :company, :sample_type, :headers, :content, :sheets

  def init
    self.company = user.company
  end

  def validate
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
    rcv = 0
    brcv = 0
    company.items.where(active: true).each do |item|
      list = [item.item_number, item.description, item.rate, item.hsn_sac, item.item_code, item.category&.name, item.category_id]
      if item.rate_contract_vendors.present?
        rcv  = item.rate_contract_vendors.count
        brcv = (rcv > brcv) ? rcv : brcv
        item.rate_contract_vendors.each do |rc|
          list << rc[:vendor_id]
          list << rc[:vendor_name]
        end
        Rails.logger.fatal "FROM GenerateImportSample RC item_contents,\n #{list.inspect}"
      end
      item_contents << list
    end
    if brcv > 0
      brcv.times do |i|
        item_headers << "Preferred Vendor ID #{i}"
        item_headers << "Preferred Vendor Name #{i}"
      end
    end
    self.sheets << {
        item_headers: item_headers,
        item_contents: item_contents,
        name: "Inventory Items"
    }

    location_headers = ["Location ID", "Location Name"]
    location_contents = []
    locations = Company::Locations::Index.(user, params).policy_location_filter_mapping&.leaves
    if locations.present?
      locations.each do |location|
        location_contents << [location.id, location.name]
      end
    end

    self.sheets << {
      item_headers: location_headers,
      item_contents: location_contents,
      name: 'Delivery Location'
    }

    # # adding departments to the excel sheet
    # department_headers = ["ID", "Department Name"]
    # department_contents = []
    # departments = Company::Departments::Index.(user, params)
    # # current_company.departments.each do |department|
    # if departments.policy_department_filter_mapping.present?
    #   departments.policy_department_filter_mapping.each do |department|
    #     department_contents << [department.id, department.name]
    #   end
    # end
    # self.sheets << {
    #     item_headers: department_headers,
    #     item_contents: department_contents,
    #     name: "Departments"
    # }

    # # adding Cost Centers to the excel sheet
    # cost_center_headers = ["ID", "Cost Center Name"]
    # cost_center_contents = []
    # current_company.cost_centers.vendor_payments_only.each do |cost_center|
    #   cost_center_contents << [cost_center.id, cost_center.name]
    # end
    # self.sheets << {
    #     item_headers: cost_center_headers,
    #     item_contents: cost_center_contents,
    #     name: "Cost Centers"
    # }

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

  end

  def success
    self.response = Exporter.new(user, {spreadsheet: {headers: self.headers, contents: self.content, sheets: self.sheets}}, messages)
  end

  private

  def default_headers
    [
     "Item Description",
     "Item Number",
     "Item Code",
     "Category ID",
     "Preferred Vendor ID",
     "Required By Date",
     "Delivery Location ID",
     "Purpose",
     "Quantity",
     "Unit of measurement",
     "Estimated Unit Price",
     "Estimated Total"
    ]
  end

end
