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
    item_headers = ["Item Number", "Description", "Rate", "HSN/SAC", "Item Code"]
    item_contents = []
    company.items.where(active: true).each do |item|
      item_contents << [item.item_number, item.description, item.rate, item.hsn_sac, item.item_code]
    end
    self.sheets << {
        item_headers: item_headers,
        item_contents: item_contents,
        name: "Inventory Items"
    }

    location_headers = ["Location ID", "Location Name"]
    location_contents = []
    locations = Company::Locations::Index.(user, params).policy_location_filter_mapping&.leaves
    locations.each do |location|
      location_contents << [location.id, location.name]
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
     "Preferred Vendor",
     "Required By Date",
     "Delivery Location",
     "Purpose",
     "Quantity",
     "Unit of measurement",
     "Estimated Unit Price",
     "Estimated Total"
    ]
  end

end
