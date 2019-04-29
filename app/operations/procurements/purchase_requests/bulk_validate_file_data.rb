class Procurements::PurchaseRequests::BulkValidateFileData < Procurements::PurchaseRequests::Base

  attr_accessor :item_details, :error_messages, :valid, :contents, :headers,
                :issues, :issue_item, :company_items, :items_in_sheet, :list_of_items, :items_found, :items_not_found,
                :locations

  class Procurements::PurchaseRequests::BulkValidateFileData::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :contents, :headers, :item_details, :issues

    def init
      self.contents = params[:contents]
      self.headers = params[:headers]
      self.item_details = params[:item_details]
      self.issues = params[:issues]
    end

  end

  class Procurements::PurchaseRequests::BulkValidateFileData::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter

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

    self.locations = Company::Locations::Index.(user, params).policy_location_filter_mapping&.leaves
    Rails.logger.fatal "FROM BulkValidateFileData LOCATION INIT,\n #{self.locations.inspect}"
    
    category = current_company.categories.inward_invoice_items_only
    self.category_ids = category.pluck(:id) rescue []

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
      item_code = item[:item_code] || item["item_code"]
      category_id = item[:category_id] || item["category_id"]
      preferred_vendor = item[:preferred_vendor] || item["preferred_vendor"]
      required_by_date = item[:required_by_date] || item["required_by_date"]
      delivery_location = item[:delivery_location] || item["delivery_location"]
      purpose = item[:purpose] || item["purpose"]
      quantity = item[:quantity] || item["quantity"]
      unit_of_measurement = item[:unit_of_measurement] || item["unit_of_measurement"]
      unit_price = item[:unit_price] || item["unit_price"]
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

      unless validate_amount unit_price
        self.valid = false
        self.error_messages << "Unit Price entered has non-numeric characters."
        self.issue_item[:unit_price] = "Unit Price entered has non-numeric characters."
      end

      if preferred_vendor.present?
        unless preferred_vendor.to_i.to_s == preferred_vendor
          self.valid = false
          self.error_messages << "Please input the ID of the Preferred Vendor from the Items Sheet"
          self.issue_item[:preferred_vendor] = "Please input the ID of the Preferred Vendor from the Items Sheet."
        end
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
      if required_by_date.blank?
        self.valid = false
        self.error_messages << "Please provide the Required delivery date of the item."
        self.issue_item[:required_by_date] = "Please provide the Required delivery date of the item."
      end

      unless validate_date required_by_date
        self.valid = false
        self.error_messages << "Required delivery date provided is not a valid date."
        self.issue_item[:required_by_date] = "Required delivery date provided is not a valid date."
      end

      # if department_id.blank?
      #   self.valid = false
      #   self.error_messages << "Please provide the department for which the item would be purchased."
      #   self.issue_item[:quantity] = "Please provide the department for which the item would be purchased."
      # end

      if delivery_location.blank?
        self.valid = false
        self.error_messages << "Please provide the delivery location for this item."
        self.issue_item[:delivery_location] = "Please provide the delivery location for this item."
      end

      if self.locations.present? && delivery_location.present?
        location_ids = self.locations.pluck(:id)
        Rails.logger.fatal "FROM BulkValidateFileData LOCATIONs,\n #{location_ids}"
        Rails.logger.fatal "FROM BulkValidateFileData LOCATION CHECK,\n #{location_ids.include?(delivery_location.to_i) }"
        unless location_ids.include? delivery_location.to_i
          self.valid = false
          self.error_messages << "Company delivery location was not found. Please recheck the excel sheet and input the correct delivery location id."
          self.issue_item[:delivery_location] = "Company delivery location was not found. Please recheck the excel sheet and input the correct delivery location id."
        end
      end

      unless validate_amount quantity
        self.valid = false
        self.error_messages << "Quantity entered has non-numeric characters."
        self.issue_item[:quantity] = "Quantity entered has non-numeric characters."
      end

      unless self.category_ids.include? category_id.to_i
        self.valid = false
        self.error_messages << "Entered category ID not found for this company. Please recheck the Category sheet for the list of IDs."
        self.issue_item[:quantity] = "Entered category ID not found for this company. Please recheck the Category sheet for the list of IDs."
      end

      item[:errors] = self.error_messages.to_sentence if self.error_messages.present?

      if valid
        Rails.logger.fatal "FROM BulkValidateFileData LOCATION VALID,\n #{self.locations.inspect}"
        if self.locations.present? && delivery_location.present?
          location = self.locations.find_by(id: delivery_location)
          item[:delivery_location_name] = location.name
        end
        
        if preferred_vendor.present?
          if preferred_vendor.to_i.to_s == preferred_vendor
            all_rc = RateContracts::Index.(user, params)
            Rails.logger.fatal "FROM BulkValidateFileData RATECONTRACTS,\n #{all_rc.inspect}"
            rc = all_rc&.rate_contracts
            if rc.present?
              item[:preferred_vendor_name] = rc.find_by(vendor_id: preferred_vendor)&.vendor&.name
            else
              item[:preferred_vendor_name] = ""
            end
          end
        end

        item[:estimated_value] = quantity.to_i * unit_price.to_i
      end

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
    Procurements::PurchaseRequests::BulkValidateFileData::SuccessPresenter.new(user, params, messages)
  end

  def failure
    params[:contents] = self.contents
    params[:headers] = self.headers
    params[:issues] = self.issues
    Procurements::PurchaseRequests::BulkValidateFileData::FailurePresenter.new(user, params, messages)
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

  def validate_date(date)
    valid = Date.parse(date) rescue false
    if valid
      true
    end
    valid
  end

  def retrieve_header_names
    [
     "Item Description",
     "Item Number",
     "Item Code",
     "Category ID",
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