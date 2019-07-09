class Budgets::GenerateSampleFile < Budgets::Base

  attr_accessor :sample_file, :company, :headers, :content, :sheets

  def pre_validate

  end
  
  def init
    self.company = user.company
  end

  def process
    self.headers = default_headers
    self.content = (params[:content].present?) ? params[:content] : []

    self.sheets = [
        {
            item_headers: self.headers,
            item_contents: self.content,
            name: "Create Sub-Budgets for #{self.budget&.name}"
        }
    ]

    # adding user IDs to the sheet
    # user_headers = ["User Name", "User ID"]
    # user_contents = []
    # self.company.users.each do |user|
    #   user_contents << [user.name, user.id]
    # end
    # self.sheets << {
    #     item_headers: user_headers,
    #     item_contents: user_contents,
    #     name: "Users"
    # }

    # adding category IDs to the sheet
    categories_headers = ["Category Name", "Category ID"]
    categories_contents = []
    self.company.categories.each do |category|
      categories_contents << [category.name, category.id]
    end
    self.sheets << {
        item_headers: categories_headers,
        item_contents: categories_contents,
        name: "Categories"
    }

    # adding departments to the sheet
    department_headers = ["Department Name", "Department ID"]
    department_contents = []
    self.company.departments.each do |department|
      department_contents << [department.name, department.id]
    end
    self.sheets << {
        item_headers: department_headers,
        item_contents: department_contents,
        name: "Departments"
    }

    # adding locations to the sheet
    location_headers = ["Location Name", "Location ID"]
    location_content = []
    self.company.locations.each do |location|
      location_content << [location.name, location.id]
    end
    self.sheets << {
        item_headers: location_headers,
        item_contents: location_content,
        name: "Location"
    }

    # adding vendors to the sheet
    # vendor_headers = ["Vendor Name", "Vendor ID"]
    # vendor_content = []
    # self.company.yes_bank_vendors.authorized.each do |vendor|
    #   vendor_content << [vendor.name, vendor.id]
    # end
    # self.sheets << {
    #     item_headers: vendor_headers,
    #     item_contents: vendor_content,
    #     name: "Vendors"
    # }
  end

  def success
    self.response = Exporter.new(user, {xlsx: {headers: self.headers, contents: self.content, sheets: self.sheets}}, messages)
  end

  private

  def default_headers
    [
        "Budget Name",
        "Amount",
        "Start Date (dd-mm-yyyy)",
        "End Date (dd-mm-yyyy)",
        "Categories Budgetable",
        "Departments Budgetable",
        "Locations Budgetable",
        "Expense? (Y/N)",
        "Payment? (Y/N)",
        "Purchase Order? (Y/N)"
    ]
  end

end