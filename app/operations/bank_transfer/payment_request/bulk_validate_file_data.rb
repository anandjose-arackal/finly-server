class BankTransfer::PaymentRequest::BulkValidateFileData < BankTransfer::PaymentRequest::Base

  attr_accessor :order_details, :error_messages, :valid, :contents, :headers,
                :requested_amount, :issues, :issue_item, :ghost_invoice, :payment_order_custom_fields, :from_payment_agreement,
                :mandatory_fields, :drop_down_fields, :drop_down_field_ids,
                :tds_slab_ids, :all_departments_ids, :all_category_ids, :all_cost_center_ids

  class BankTransfer::PaymentRequest::BulkValidateFileData::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :contents, :headers, :order_details, :requested_amount, :issues

    def init
      self.contents = params[:contents]
      self.headers = params[:headers]
      self.order_details = params[:order_details]
      self.requested_amount = params[:requested_amount]
      self.issues = params[:issues]
    end

  end

  class BankTransfer::PaymentRequest::BulkValidateFileData::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :contents, :headers, :issues

    def init
      self.contents = params[:contents]
      self.headers = params[:headers]
      self.issues = params[:issues]
    end

  end

  def init
    self.order_details = params[:order_details]
    self.contents = []
    self.headers = retrieve_header_names
    # setting the valid as true here, so that even if one line item failed in the
    # below validations it will return false
    self.valid = true
    self.requested_amount = 0
    self.from_payment_agreement = !!StringUtils.to_bool(params[:from_payment_agreement])

    # Payment agreement custom fields has no effect here
    unless from_payment_agreement
      self.payment_order_custom_fields = self.user.company.field_configurations.non_deleted.root_fields.with_field_parent_type(FieldParentType.id_for(:invoice)).to_a
      self.payment_order_custom_fields.each do |custom_field_config|
        case custom_field_config.field_type_id
        when FieldType.id_for(:drop_down), FieldType.id_for(:multiselect)
          self.headers << "#{custom_field_config.field_name} ID"
        else
          self.headers << "#{custom_field_config.field_name}"
        end
      end

      self.mandatory_fields = self.payment_order_custom_fields.map {|field| field if field.mandatory}.compact # pluck fields which are mandatory

      self.drop_down_fields = self.payment_order_custom_fields.map {|field| field if field.field_type_id == FieldType.id_for(:drop_down)}.compact # pluck fields which are of type drop down

      self.drop_down_field_ids = self.drop_down_fields.map {|df| {df.id => df.drop_down_items.pluck(:id)}} # [{drop_down_field_configuration_id => [array of possible drop down fields]}]
    end

    self.issues = []

    result = TdsSlabs::Index.(user, params)
    self.tds_slab_ids = result.tds_slabs.pluck(:id)

    all_departments = Company::Departments::Index.(user, params)
    self.all_departments_ids = all_departments&.policy_department_filter_mapping&.pluck(:id)

    all_categories = Categories::Index.(current_user, params)
    self.all_category_ids = all_categories.categories.leaves.pluck(:id) rescue []

    all_cost_centers = current_company.cost_centers.vendor_payments_only
    self.all_cost_center_ids = all_cost_centers.pluck(:id) rescue []

    # Rails.logger.fatal "FROM BulkValidateFileData,\n #{params.inspect}"
    
  end

  def validate

  end

  def process
    self.order_details.each do |item|
      bank_account_no = item[:bank_account_number] || item["bank_account_number"]
      ifsc = item[:ifsc] || item["ifsc"]
      name = item[:name].present? ? item[:name] : item[:bank_account_name]
      business_name = item[:business_name].present? ? item[:business_name] : item[:name]
      authorized = item[:authorized] || item["authorized"]
      amount = item[:original_amount]
      advance_amount = item[:advance_amount]
      gst_type_id = item[:gst_type_id]
      inclusive_of_taxes = item[:inclusive_of_taxes]
      tax = item[:tax]
      discount = item[:discount]
      tds_slab_id = item[:tds_slab_id]
      category_id = item[:category_id]
      cost_center_id = item[:cost_center_id]
      department_id = item[:department_id]
      invoice_number = item[:invoice_number]
      invoice_date = item[:invoice_date] || item[:date]
      invoice_due_date = item[:invoice_due_date] || item[:due_date]
      note = item[:note]
      external_reference_id = item[:external_reference_id]
      custom_fields_key = item[:custom_fields] || item["custom_fields"]

      # generating custom field data
      custom_fields = {}
      drop_down_custom_fields = {}
      text_fields = {}
      multi_select_custom_fields = {}
      empty_fields = []

      unless from_payment_agreement
      # field_configurations = self.user.company.field_configurations.non_deleted.with_field_parent_type(FieldParentType.id_for(:invoice))
      # field_configurations.each do |field|
        self.payment_order_custom_fields.each do |field|
          field_name = field.field_name.gsub(" ", "_").underscore

          if item[field_name.to_sym].present? or (custom_fields_key.present? and custom_fields_key[field.id.to_s].present?)
            if field.field_type_id == FieldType.id_for(:multiselect)
              if custom_fields_key.present?
                custom_fields[field.id] = [custom_fields_key[field.id.to_s]].flatten if custom_fields_key[field.id.to_s].present?
                multi_select_custom_fields[field.id] = custom_fields_key[field.id.to_s] if custom_fields_key[field.id.to_s].present?
              else
                custom_fields[field.id] = [item[field_name.to_sym]].flatten
                multi_select_custom_fields[field.id] = [item[field_name.to_sym]].flatten
              end
            elsif field.field_type_id == FieldType.id_for(:drop_down)

              if custom_fields_key.present?
                custom_fields[field.id] = custom_fields_key[field.id.to_s] if custom_fields_key[field.id.to_s].present?
                drop_down_custom_fields[field.id] = custom_fields_key[field.id.to_s] if custom_fields_key[field.id.to_s].present?
              else
                custom_fields[field.id] = item[field_name.to_sym]
                drop_down_custom_fields[field.id] = item[field_name.to_sym]
              end

            elsif field.field_type_id == FieldType.id_for(:text)

              if custom_fields_key.present?
                custom_fields[field.id] = custom_fields_key[field.id.to_s] if custom_fields_key[field.id.to_s].present?
                text_fields[field.id] = custom_fields_key[field.id.to_s] if custom_fields_key[field.id.to_s].present?
              else
                custom_fields[field.id] = item[field_name.to_sym]
                text_fields[field.id] = item[field_name.to_sym]
              end

            end
          else
            empty_fields << field.id
          end
        end
      end

      self.error_messages = []
      self.issue_item = {}
      self.issue_item[:custom_fields] = []

      # item[:custom_fields] = (custom_fields_key.present?) ? custom_fields_key : custom_fields
      item[:custom_fields] = custom_fields
      item[:text_fields] = text_fields
      item[:drop_down_fields] = drop_down_custom_fields
      item[:multi_select_fields] =  multi_select_custom_fields

      unless from_payment_agreement
        # find all fields which are required but left empty by user
        required_fields = self.mandatory_fields.select {|field| field if empty_fields.include? field.id }

        if required_fields.present?
          self.error_messages << required_fields.pluck(:field_name).map {|field| field + " cannot be empty"}.join(", ")
          self.valid = false
          # self.issue_item[:custom_fields] = required_fields.pluck(:field_name).map {|field| field + " cannot be empty"}
          self.issue_item[:custom_fields] = required_fields.pluck(:id, :field_name).map {|id, field| {"id" => id, "error" => (field + " cannot be empty")}}
        end

        # validate if dropdown fields entered matches the data setup in the organization account
        if drop_down_custom_fields.present?
          drop_down_custom_fields.each do |key, value|
            wanted_hash = self.drop_down_field_ids.find {|ddfi| ddfi if ddfi.keys.include? key} # find relevant drop down field configuration
            unless wanted_hash[key].include?(value.to_i) # check if value entered matches stored possible value
              correct_field = drop_down_fields.find {|field| field if field.id == key}
              self.error_messages << correct_field.field_name.to_s + " is not an acceptable value"
              self.valid = false
              # self.issue_item[:custom_fields] << correct_field.field_name.to_s + " is not an acceptable value"
              self.issue_item[:custom_fields] << { "id" => key, "error" => correct_field.field_name.to_s + " is not an acceptable value" }
            end
          end
        end
      end

      # adding the custom fields for the particular invoice, using a ghost invoice
      # self.ghost_invoice = Invoice.new
      # custom_fields = {custom_fields: item[:custom_fields]} || {}
      # custom_fields[:user] = user
      # custom_fields[:reset_fields] = true
      # custom_fields[:save] = false
      # CustomField::SetFields.(self.ghost_invoice, FieldParentType.id_for(:invoice), custom_fields)

      # op = CustomField::Validate.(self.ghost_invoice)
      # unless op.success?
      #   self.error_messages << op.messages[:error]
      #   self.valid = false
      #   self.issue_item[:custom_fields] = op.messages[:error]
      # end

      # new requirement
      # SET key as array to hold mupltiple errors
      # self.issue_item[:ifsc] = []
      # self.issue_item[:tax] = []
      # self.issue_item[:discount] = []
      # self.issue_item[:original_amount] = []
      # self.issue_item[:bank_account_number] = []

      # Check if bank account number is present
      if bank_account_no.blank?
        self.valid = false
        self.error_messages << 'No Bank Account entered'
        self.issue_item[:bank_account_number] = 'No Bank Account entered'
      end

      unless authorized
        if business_name.blank?
          self.valid = false
          self.error_messages << 'Please specify the business name to be used for the vendor'
          self.issue_item[:business_name] = 'Please specify the business name to be used for the vendor'
        end
      end


      # For now not making it mandatory to select tax type
      # if gst_type_id.blank?
      #   self.valid =false
      #   self.error_messages << "Please select a Tax Type"
      #   self.issue_item[:gst_type_id] = "Please select a Tax Type"
      # end

      # if tax.blank?
      #   self.valid =false
      #   self.error_messages << "Please select a relevant tax amount"
      #   self.issue_item[:tax] = "Please select a relevant tax amount"
      # end

      # check for format of the Bank account number
      # pattern = Regexp.new(Constants::VALID_BANK_ACCOUNT)
      # unless bank_account_no =~ pattern
      unless validate_bank_account_number bank_account_no
        self.valid = false
        self.error_messages << "Invalid Bank Account Number entered"
        self.issue_item[:bank_account_number] = 'Invalid Bank Account Number entered'
      end

      # Check if the amount is present
      unless validate_amount(amount.to_s)
        self.valid = false
        self.error_messages << 'Invalid amount'
        self.issue_item[:original_amount] = 'Invalid amount'
      end

      # Check if the advance amount is present and valid
      unless advance_amount.blank? || validate_amount(advance_amount.to_s)
        self.valid = false
        self.error_messages << 'Invalid advance amount'
        self.issue_item[:advance_amount] = 'Invalid advance amount'
      end

      if advance_amount.present? && validate_amount(advance_amount.to_s)
        if advance_amount.to_f > amount.to_f
          self.valid = false
          self.error_messages << 'Advance amount is more than the original amount'
          self.issue_item[:advance_amount] = 'Advance amount is more than the original amount'
        end
      end

      # check if the ifsc is present
      if ifsc.blank?
        self.valid = false
        self.error_messages << 'IFSC cannot be blank'
        self.issue_item[:ifsc] =  'IFSC cannot be blank'
      end

      # check for format of the IFSC
      pattern = Regexp.new(Constants::VALID_IFSC)
      unless ifsc =~ pattern
        self.valid = false
        self.error_messages << "Invalid IFSC"
        self.issue_item[:ifsc] = 'Invalid IFSC'
      end

      if external_reference_id.present?
        if ::Payment.with_company_id(user.company_id).find_by(external_reference_id: external_reference_id)
          self.valid = false
          self.error_messages << "This external reference ID is already taken"
          self.issue_item[:external_reference_id] = "This external reference ID is already taken"
        end
      end

      # adding all invoice specific validations here for the payment
      # 
      # BENEFICIARY PAYMENTS WOULD NO LONGER REQUIRE INVOICES
      # 
      unless invoice_date.blank? || validate_date(invoice_date)
        self.valid = false
        self.error_messages << "Invalid invoice date"
        self.issue_item[:invoice_date] = 'Invalid invoice date'
      end

      unless invoice_due_date.blank? || validate_date(invoice_due_date)
        self.valid = false
        self.error_messages << "Invalid due date"
        self.issue_item[:invoice_due_date] = 'Invalid due date'
      end

      

      unless invoice_number.blank? || validate_invoice_number(invoice_number)
        self.valid = false
        self.error_messages << "Invoice number can only have letters, numbers, dashes, ampersand and forward slash and no other special characters"
        self.issue_item[:invoice_number] = "Invoice number can only have letters, numbers, dashes, ampersand and forward slash and no other special characters"
      end

      unless validate_rate tax, 1, amount
        self.valid = false
        self.error_messages << "Invalid tax entered"
        self.issue_item[:tax] = 'Invalid tax entered'
      end

      unless validate_rate discount, 1, amount
        self.valid = false
        self.error_messages << "Invalid discount entered"
        self.issue_item[:discount] = 'Invalid discount entered'
      end

      if tds_slab_id.present?
        unless self.tds_slab_ids.include? tds_slab_id.to_i
          self.valid = false
          self.error_messages << "Invalid TDS Slab ID"
          self.issue_item[:tds_slab_id] = "Invalid TDS Slab ID"
        end
      end

      if department_id.present? && self.all_departments_ids.present?
        unless (self.all_departments_ids.include?(department_id.to_i) )
          self.valid = false
          self.error_messages << "Department does not exist for this policy or you are not authorized to make payments for this department."
          self.issue_item[:department_id] = "Department does not exist for this policy or you are not authorized to make payments for this department."
        end
      end

      if category_id.present?
        unless self.all_category_ids.include? category_id.to_i
          self.valid = false
          self.error_messages << "Entered category ID not found for this company. Please recheck the list of Categories."
          self.issue_item[:category_id] = "Entered category ID not found for this company. Please recheck the list of Categories."
        end
      end

      if cost_center_id.present?
        unless self.all_cost_center_ids.include? cost_center_id.to_i
          self.valid = false
          self.error_messages << "Entered cost center ID not found for this company. Please recheck the list of Cost Centers."
          self.issue_item[:cost_center_id] = "Entered cost center ID not found for this company. Please recheck the list of Cost Centers."
        end
      end

      if self.valid
        payable_amount = calculate_tds(inclusive_of_taxes, amount, advance_amount, tds_slab_id, tax)
        # self.requested_amount += amount.to_f
        self.requested_amount += payable_amount.to_f
      else
        item.delete(:custom_fields)
        item.delete(:text_fields)
        item.delete(:drop_down_fields)
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
    params[:order_details] = self.order_details
    params[:requested_amount] = self.requested_amount
    params[:issues] = self.issues
    BankTransfer::PaymentRequest::BulkValidateFileData::SuccessPresenter.new(user, params, messages)
  end

  def failure
    params[:contents] = self.contents
    params[:headers] = self.headers
    params[:issues] = self.issues
    BankTransfer::PaymentRequest::BulkValidateFileData::FailurePresenter.new(user, params, messages)
  end


  private

  def validate_rate(rate, rate_type_id, amount = nil)
    if rate.blank?
      return true
    end
    case rate_type_id
      when 1, '1'
        if rate.to_f >= 100
          return false
        end
      when 2, '2'
        return true
      else
        # do nothing?
    end
    true
  end

  def validate_date(date)
    if date.blank?
      return true
    end
    date_obj = Date.parse(date) rescue nil
    if date_obj.blank?
      return false
    end
    true
  end

  def validate_invoice_number(invoice_number)
    ( /\A[a-zA-Z0-9 \\\/\-\#\&]*\Z/.match(invoice_number) ) ? true : false
  end

  # def validate_amount(amount)
  #   if amount.blank? || !amount.to_f&.is_a?(Numeric) || amount.to_f < 0
  #     return false
  #   end
  #   true
  # end

  def calculate_tds(inclusive_of_taxes, original_amount, advance_amount, tds_slab_id, tax)
    net_amount = 0
    if inclusive_of_taxes

      # calculate_inclusive_taxes
      gross_amount = TaxCalculationUtils.inclusive_tax_amount(original_amount.to_f, (tax.to_i))
      # calculate_tds
      tds = TdsRatesList.find(tds_slab_id).tds rescue 0
      new_gross_amount = TaxCalculationUtils.tds_amount(gross_amount, tds)
      tds_amount = gross_amount - new_gross_amount

      net_amount = original_amount.to_f - tds_amount - advance_amount.to_f

    else 

      # calculate_exclusive_taxes
      net_amount = TaxCalculationUtils.exclusive_tax_amount(original_amount.to_f, (tax.to_i))
      tax_amount = net_amount - original_amount.to_f
      # calculate_tds
      tds = TdsRatesList.find(tds_slab_id).tds rescue 0
      new_gross_amount = TaxCalculationUtils.tds_amount(original_amount.to_f, tds.to_i)
      tds_amount = original_amount.to_f - new_gross_amount

      net_amount = original_amount.to_f + tax_amount - tds_amount - advance_amount.to_f
    end
  end

  def validate_bank_account_number account_number
    unless Constants::VALID_BANK_ACCOUNT.match(account_number)
    # if !/\A\d+\z/.match(account_number)
      return false
    end
    true
  end

  def validate_amount(amount)
    if amount.blank? || (!/\A\d+\.\d+\z/.match(amount) && !/\A\d+\z/.match(amount)) # check if blank or not a positive float or not a positive integer
      return false
    end
    true
  end

  def retrieve_header_names
    [
        "Name",
        "Business Name",
        "Account Number",
        "IFSC",
        "Sub Total",
        "Inclusive of Taxes? (Y/N)",
        "GST Type (1 - IGST ; 2 - CGST/SGST)",
        "Tax Rate",
        "Advance Amount",
        "Discount Rate",
        "TDS Slab ID",
        "Category ID",
        "Cost Center ID",
        "Department ID",
        "Invoice Number",
        "Invoice Date (dd-mm-yyyy)",
        "Due Date (dd-mm-yyyy)",
        "Narration",
    ]
  end

end