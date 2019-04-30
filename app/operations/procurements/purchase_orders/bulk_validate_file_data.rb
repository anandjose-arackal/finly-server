class Procurements::PurchaseOrders::BulkValidateFileData < Procurements::PurchaseOrders::Base

  attr_accessor :item_details, :error_messages, :valid, :contents, :headers,
                :issues, :issue_item, :company_items, :items_in_sheet, :list_of_items, :items_found, :items_not_found,
                :all_departments, :all_departments_ids, :category_ids, :category, :cost_centers

  class Procurements::PurchaseOrders::BulkValidateFileData::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :contents, :headers, :item_details, :issues

    def init
      self.contents = params[:contents]
      self.headers = params[:headers]
      self.item_details = params[:item_details]
      self.issues = params[:issues]
    end

  end

  class Procurements::PurchaseOrders::BulkValidateFileData::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :contents, :headers, :issues

    def init
      self.contents = params[:contents]
      self.headers = params[:headers]
      self.issues = params[:issues]
    end

  end

  def init
    self.item_details = params[:item_details]
    self.contents = []
    self.headers = retrieve_header_names
    # setting the valid as true here, so that even if one line item failed in the
    # below validations it will return false
    self.valid = true

    self.issues = []

    Rails.logger.fatal "FROM BulkValidateFileData,\n #{params.inspect}"

    self.company_items = user.company.items

    self.all_departments = Company::Departments::Index.(user, params)
    self.all_departments_ids = self.all_departments&.policy_department_filter_mapping&.pluck(:id)
     Rails.logger.fatal "FROM BulkValidateFileData DEPARTMENT IDS,\n #{self.all_departments_ids.inspect}"

    self.category = current_company.categories.inward_invoice_items_only
    self.category_ids = category.pluck(:id) rescue []

    self.cost_centers = user.company.cost_centers
    
  end

  def validate
    if self.company_items.blank?
      add_message :error, "Your inventory list is empty."
      return
    end

  end

  def pre_process
    self.items_in_sheet = self.item_details.pluck(:item_number)

    self.list_of_items = self.company_items.where(item_number: self.items_in_sheet)

    self.items_found = self.list_of_items.pluck(:item_number)

    self.items_not_found = (self.items_in_sheet - self.items_found)
  end

  def process
    self.item_details.each do |item|
      description = item[:description] || item["description"]
      item_number = item[:item_number] || item["item_number"]
      department_id = item[:department_id] || item["department_id"]
      cost_center_id = item[:cost_center_id] || item["cost_center_id"]
      comment = item[:comment] || item["comment"]
      item_code = item[:item_code] || item[:item_code]
      category_id = item[:category_id] || item["category_id"]
      hsn_sac = item[:hsn_sac] || item[:hsn_sac]
      quantity = item[:quantity] || item[:quantity]
      unit_of_measurement = item[:unit_of_measurement] || item["unit_of_measurement"]
      rate = item[:rate] || item["rate"]
      discount = item[:discount] || item["discount"]
      tax = item[:tax] || item["tax"]
      total = item[:total] || item["total"]

      self.error_messages = []
      self.issue_item = {}

      if item_number.nil? or items_not_found.include? item_number
        self.valid = false
        self.error_messages << "Unable to find this item number in inventory list"
        self.issue_item[:item_number] = "Unable to find this item number in inventory list"
      else
        single_item = self.list_of_items.map {|item| item if item.item_number.downcase == item_number.downcase}&.compact&.first
        item[:single_item] = single_item
      end

      unless validate_amount rate
        self.valid = false
        self.error_messages << "Rate entered has non-numeric characters."
        self.issue_item[:rate] = "Rate entered has non-numeric characters."
      end

      # Removing it for now
      # if unit_of_measurement.blank?
      #   self.valid = false
      #   self.error_messages << "Unit of Measurement for the item has not been provided."
      #   self.issue_item[:unit_of_measurement] = "Unit of Measurement for the item has not been provided."
      # end

      if quantity.blank?
        self.valid = false
        self.error_messages << "Please input the quantity."
        self.issue_item[:quantity] = "Please input the quantity."
      end

      if department_id.blank?
        self.valid = false
        self.error_messages << "Please provide the department for which the item would be purchased."
        self.issue_item[:department_id] = "Please provide the department for which the item would be purchased."
      end

      if self.all_departments_ids.blank?
        self.valid = false
        self.error_messages << "You do not seem to be part of any policy and department. Please make the changes from the Organization Account from the main menu."
        self.issue_item[:department_id] = "You do not seem to be part of any policy and department. Please make the changes from the Organization Account from the main menu."
      end

      if department_id.present? && self.all_departments_ids.present?
        Rails.logger.fatal "FROM BulkValidateFileData DEPARTMENT CHECK,\n #{self.all_departments_ids.include?(department_id.to_i) }"
        unless (self.all_departments_ids.include?(department_id.to_i) )
          self.valid = false
          self.error_messages << "Department does not exist for this policy or you are not authorized to make purchases for this department."
          self.issue_item[:department_id] = "Department does not exist for this policy or you are not authorized to make purchases for this department."
        end
      end

      unless validate_amount quantity
        self.valid = false
        self.error_messages << "Quantity entered has non-numeric characters."
        self.issue_item[:quantity] = "Quantity entered has non-numeric characters."
      end

      if category_id.present?
        unless self.category_ids.include? category_id.to_i
          self.valid = false
          self.error_messages << "Entered category ID not found for this company. Please recheck the Category sheet for the list of IDs."
          self.issue_item[:quantity] = "Entered category ID not found for this company. Please recheck the Category sheet for the list of IDs."
        end
      end

      # unless validate_hsn_sac hsn_sac
      #   self.valid = false
      #   self.error_messages << "HSN/SAC is invalid. Please recheck."
      #   self.issue_item[:hsn_sac] = "HSN/SAC is invalid. Please recheck."
      # end

      if valid
        item[:category_name] = self.category.find_by(id: category_id)&.name

        if department_id.present? && self.all_departments_ids.present?
          item[:department_name] = self.all_departments.policy_department_filter_mapping&.find_by(id: department_id)&.name
        end

        if cost_center_id.present? && self.cost_centers.present?
          item[:cost_center_name] = self.cost_centers.where(id: cost_center_id)&.first&.name
        end

      end

      item[:errors] = self.error_messages.to_sentence if self.error_messages.present?

      self.contents << item.values

      #self.issue_item.each {|k, v| self.issue_item.delete(k) if v.blank?} # delete unnecessary keys which have no error
      self.issues << self.issue_item
    end
  end

  def success?
    self.valid
  end

  def failure?
    self.valid
  end

  def success
    params[:contents] = self.contents
    params[:headers] = self.headers
    params[:item_details] = self.item_details
    params[:issues] = self.issues
    Procurements::PurchaseOrders::BulkValidateFileData::SuccessPresenter.new(user, params, messages)
  end

  def failure
    params[:contents] = self.contents
    params[:headers] = self.headers
    params[:issues] = self.issues
    Procurements::PurchaseOrders::BulkValidateFileData::FailurePresenter.new(user, params, messages)
  end


  private

  # def validate_hsn_sac(hsn_sac)
  #   ( /\A(\d{6}|\d{8})\Z/.match(hsn_sac)) ? true : false
  # end

  def validate_amount(amount)
    if amount.blank? || (!/\A\d+\.\d+\z/.match(amount) && !/\A\d+\z/.match(amount)) # check if blank or not a positive float or not a positive integer
      return false
    end
    true
  end

  def retrieve_header_names
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