class BankTransfer::PaymentRequest::Beneficiary::BeneficiaryPaymentsBackgroundOptimized < BackgroundOperation

# This operation is highly optimized. Before modifying read carefully.
# 

                                     
# TODO 
# define method to create new bank accounts DONE
# define variables
# callbacks list
# make sure vendor created is unique when bulk insert
# agreement based payments
# setup beneficiary payments mapping without index
# add field and index in bank_accounts, vendors, beneficiary_payments
# add index in field_text, custom_fields, field_drop_down_selection
# beautify

sidekiq_options queue: :payments_queue

attr_accessor :bank_payment_request, :payments_attributes, :payment_mode, :options,
              :company_id, :execute, :payment_params, :beneficiary_payments, :from_payment_agreement, :agreement_type, :agreement_related_document_id, :ticket_type, :security_deposit, :beneficiary_payment, :security_deposits, :agreement_beneficiary_payment, :agreement_security_deposit, 
              :init_text_field, :init_drop_down_field, :import_id, :import_number, :import_date,
              :company, :new_accounts, :new_vendors, :bank_accounts, :beneficiary_payments, :original_amounts, :advance_amounts, :payment_amounts,
              :initiating_account, :user, :invoices, :payments, :transfer_mode, :tax_rate_id, :logger, :log_data

def self.call(user, options = {})
  self.new.perform(user, options)
end

def perform(user, options, request_store_hash = nil)
	self.logger = LogStashLogger.new(type: :file, path: 'log/logstash_payments_creation.log', sync: true)
	self.log_data = {}
	self.log_data[:start_time] = DateTime.now.utc
	self.log_data[:klass_name] = self.class.name
	self.log_data[:job] = "payments_creation"
  load_request_store request_store_hash
  if options.present? and options.is_a?(Hash)
    options = options.with_indifferent_access
  end
  self.bank_payment_request = BankPaymentRequest.find_by(id: options[:bank_payment_request_id])
  self.log_data[:bank_payment_request_id] = self.bank_payment_request&.id
  self.payments_attributes = options[:payments_attributes]
	self.log_data[:number_of_payments] = self.payments_attributes.count
  self.from_payment_agreement = options[:created_from_payment_agreement]
  # Payment agreement type
  self.agreement_type = options[:agreement_type]
  # For payment agreement type id
  self.agreement_related_document_id = options[:document_id]
  self.ticket_type = options[:ticket_type]
  self.options = options
  self.run
end

def pre_validate
  if self.bank_payment_request.blank?
    add_message :error, "Payment order not found"
    return
  end
end

def initialize
	
end

def init
	setup
end


def process
	ActiveRecord::Base.transaction do
		split_bank_accounts
		build_new_vendors if self.new_accounts.present?
		get_all_bank_accounts
		setup_beneficiary_payment
		setup_payments
		build_custom_fields
	end

	self.log_data[:end_time] = DateTime.now.utc
	self.logger.info(self.log_data)
end

def setup
	self.company = self.bank_payment_request.owner.company.name.split.first.parameterize.to_s
	self.company_id = self.bank_payment_request.owner.company_id
	self.log_data[:company_name] = self.bank_payment_request.owner.company.name
	self.log_data[:company_id] = self.company_id
	date = DateTime.now.strftime('%b-%d-%a-%H-%M-%S').downcase
	rnd = SecureRandom.hex(11)
	self.import_id = (company + "-" + date + "-" + rnd).freeze
	self.import_number = rand(100_000_000..999_999_999)
	self.import_date = DateTime.now + rand(12..51).years
	self.user = self.bank_payment_request.owner
	self.initiating_account = retrieve_initiating_account(user.company)
end

def split_bank_accounts
	account_numbers = self.payments_attributes.pluck :bank_account_number
	ifscs = self.payments_attributes.pluck :ifsc
	account_names = self.payments_attributes.pluck :bank_account_name

	bank_accounts = BankAccount.non_deleted.where(account_number: account_numbers, ifsc: ifscs, company_id: self.company_id, account_owner_type: YesBankVendor.name)
	
	account_numbers = bank_accounts.pluck :account_number
	ifscs = bank_accounts.pluck :ifsc

	existing_accounts = self.payments_attributes.select {|h| account_numbers.include?(h[:bank_account_number]) && ifscs.include?(h[:ifsc])}
	self.new_accounts = self.payments_attributes - existing_accounts
	
end

def build_new_vendors
	klass, import_id_column, import_number_column = strategy(YesBankVendor)

	vendors = Array.new(self.new_accounts.size, klass)
	YesBankVendor.import vendors

	if import_id_column.present? or import_number_column.present?
		kolumn, kolumn_value = import_id_column.present? ? [import_id_column, import_id] : [import_number_column, import_number]
		vendors = YesBankVendor.include_soft_deleted.where(kolumn => kolumn_value, :created_at => import_date)
	else
		vendors = YesBankVendor.include_soft_deleted.where(created_at: import_date)
	end


	self.new_accounts.each_with_index do |account, index|
		business_name = account[:business_name] || account[:name]
		# vendors << YesBankVendor.new(name: account[:name], company_id: self.company_id, business_name: business_name)
		vendors[index].name = account[:name]
		vendors[index].company_id = self.company_id
		vendors[index].business_name = account[:business_name]
	end
	exec_statement(vendors.to_a, false, false, true, true)
	# self.new_vendors = YesBankVendor.include_soft_deleted.where('import_id like ?', import_id).to_a
	self.new_vendors = vendors
	# 
	build_new_bank_accounts
end

def build_new_bank_accounts
	bank_accounts = []
	self.new_accounts.each do |account|
		business_name = account[:business_name] || account[:name]

		vendor = new_vendors.find do |vendor| 
			business_name = account[:business_name].blank? ? account[:name] : account[:business_name]
			vendor if vendor.name == account[:name] && vendor.business_name == business_name
		end
		bank_accounts << BankAccount.new(name: account[:name],
																			account_number: account[:bank_account_number]&.strip,
																			ifsc: account[:ifsc]&.strip,
																			account_owner_type: vendor.class.name,
																			account_owner_id: vendor.id,
																			company_id: self.company_id,
																			default_account: true
																			)
	end
	exec_statement(bank_accounts)
	# BankAccount.import bank_accounts
	# 
end

def get_all_bank_accounts
	account_numbers = self.payments_attributes.pluck :bank_account_number
	ifscs = self.payments_attributes.pluck :ifsc
	self.bank_accounts = BankAccount.where(account_number: account_numbers, ifsc: ifscs, company_id: self.company_id, account_owner_type: YesBankVendor.name)
	# bank_accounts.update_all is_deleted: false
	hash_records = Hash[bank_accounts.map {|ba| [ba.account_number, ba]}]
	
	self.payments_attributes.each do |od|
		od[:bank_account] = hash_records[od[:bank_account_number]]
	end
	self.payments_attributes
	# 
end

def setup_beneficiary_payment
	beneficiary_details = []

	self.payments_attributes.each {|od| bp_params = beneficiary_payment_params(od); bp = BeneficiaryPayment.new(bp_params); beneficiary_details << bp}

	BeneficiaryPayment.import beneficiary_details

	# beneficiary_payments = BeneficiaryPayment.include_soft_deleted.where('import_id like ?', import_id).to_a
	fetch_beneficiary_payments = BeneficiaryPayment.include_soft_deleted.where(created_at: import_date)

	self.beneficiary_payments = BeneficiaryPayment.include_soft_deleted.where(id: fetch_beneficiary_payments.pluck(:id))

	self.payments_attributes.each_with_index do |vd, ix| 
		vd[:advance_amount] = (vd[:advance_amount].blank?) ? 0 : vd[:advance_amount]
		beneficiary_payments[ix].original_amount = Amount.new(value: vd[:original_amount], currency_id: (self.user&.company&.reporting_currency&.id || 1 ))
		beneficiary_payments[ix].advance_amount = Amount.new(value: vd[:advance_amount], currency_id: (self.user&.company&.reporting_currency&.id || 1 ))
		beneficiary_payments[ix].created_at = DateTime.now
	end

	# 

	::Parallel.map(beneficiary_payments, in_threads: 0) do |element|
		ActiveRecord::Base.connection_pool.with_connection do
			element.calculate_tax_and_amount
			element.save
		end
	end

	# 
end

def insert_beneficiary
	# TODO
	# convert array of hash to sql
end


def setup_payments
	build_amounts
	build_invoices
	build_payments
end



def build_amounts
	amounts = []
	(payments_attributes.size * 3).times do |i|
		amounts << Amount.new(value: import_number, currency_id: (self.user&.company&.reporting_currency&.id || 1 ), created_at: import_date)
	end

	Amount.import amounts

	amounts = Amount.include_soft_deleted.where(created_at: import_date)

	self.original_amounts, self.advance_amounts, self.payment_amounts = amounts.in_groups_of(((payments_attributes.size * 3) / 3), false)
	# 
	self.payments_attributes.each_with_index do |order, index|
		original_amounts[index].value = order[:original_amount]
		original_amounts[index].created_at = DateTime.now
		
		advance_amounts[index].value = order[:advance_amount] 
		advance_amounts[index].created_at = DateTime.now
		
		# payment_amounts[index].value = order[:original_amount]
		payment_amounts[index].value = beneficiary_payments[index]&.balance_due&.value
		payment_amounts[index].created_at = DateTime.now
	end

	amounts = self.original_amounts + self.advance_amounts + self.payment_amounts

	Amount.import amounts.flatten, on_duplicate_key_update: [:value]

end

def build_invoices
	klass, import_id_column, import_number_column = strategy(Invoice)

	self.invoices = Array.new(payments_attributes.size, klass)
	Invoice.import invoices

	if import_id_column.present? or import_number_column.present?
		kolumn, kolumn_value = import_id_column.present? ? [import_id_column, import_id] : [import_number_column, import_number]
		invoices = Invoice.include_soft_deleted.where(kolumn => kolumn_value, :created_at => import_date)
	else
		invoices = Invoice.include_soft_deleted.where(created_at: import_date)
	end

	self.payments_attributes.each_with_index do |payment, index|
		params = invoice_params(payment)
		params[:original_amount_id] = self.original_amounts[index].id
		params[:advance_amount_id] = self.advance_amounts[index].id
		params[:created_at] = DateTime.now
		invoices[index].assign_attributes(params)
	end

	# invoice_params.each_with_index do |params, index|
	# 	# params = invoices[index].attributes.with_indifferent_access
	# 	params[:original_amount_id] = original_amounts[index].id
	# 	params[:advance_amount_id] = advance_amounts[index].id
	# 	params[:created_at] = DateTime.now
	# 	invoices[index].assign_attributes params
	# end

	Invoice.import invoices.to_a, on_duplicate_key_update: invoices.first.attributes.keys.map(&:to_sym)
	self.invoices = invoices
end

def build_payments

	self.payments = []
	self.payments_attributes.each_with_index do |payment, index|
		# payment[:bank_account] = self.bank_accounts[index]
		bp = beneficiary_payments[index]
		params = payment_params payment
		params[:amount_id] = payment_amounts[index].id
		# params[:amount_id] = bp.balance_due&.id
		params[:invoice_id] = invoices[index].id
		params[:created_at] = import_date
		params[:beneficiary_payment_id] = bp.id
		params[:parent_type] = 'BeneficiaryPayment'
    params[:parent_id] = params[:beneficiary_payment_id]
    params.delete(:custom_fields)
    params.delete(:text_fields)
    params.delete(:drop_down_fields)
		# self.payments[index].assign_attributes params
		self.payments << ::Payment.new(params)
		# payment[:payment_id] = payments[index].id
		# payment[:invoice_id] = invoices[index].id
	end

	run_before_callbacks(self.payments)
	Payment.import self.payments

	self.payments = Payment.include_soft_deleted.where(created_at: import_date)

	# payment_params.each_with_index do |params, index|
	# 	params[:amount_id] = payment_amounts[index].id
	# 	params[:invoice_id] = invoices[index].id
	# 	params[:created_at] = DateTime.now
	# 	params[:beneficiary_payment_id] = beneficiary_payments[index].id
	# 	payments[index].assign_attributes params
	# end

	# Payment.import payments.to_a, on_duplicate_key_update: payments.first.attributes.keys.map(&:to_sym)
	Payment.import self.payments.to_a, on_duplicate_key_update: {created_at: :updated_at}
	run_after_callbacks(self.payments.to_a)

	self.payments_attributes.each_with_index do |payment, index|
		payment[:payment_id] = payments[index].id
		payment[:invoice_id] = invoices[index].id
	end

	# 
end

def build_custom_fields
	setup_text_field
	setup_drop_down_field
	
	if self.init_text_field.present?
    build_text_custom_fields
  end
  if self.init_drop_down_field.present?
    build_drop_down_custom_fields
  end
end

def post_process
	self.beneficiary_payments.update_all(status_id: BeneficiaryPaymentStatus.id_for(:unpaid)) if beneficiary_payments.present?# && !from_payment_agreement

	# now once the payment request has been created and the payments saved, we can mark it as open
  max_payment_amount = self.bank_payment_request.payment_order.payments.reload.joins(:amount).pluck(:value).max || 0
  self.bank_payment_request.update(status_id: BankPaymentRequestStatus.id_for(:open), max_payment_amount: max_payment_amount)
  self.bank_payment_request.payment_order.reload.update(payment_order_status_id: PaymentOrderStatus.id_for(:pending_approval))
  # puts 'SUCCESSFUL!'

  # Trail.import build_trails if build_trails.present?
end

def setup_text_field
	self.init_text_field = []
	self.payments_attributes.each_with_index do |payment, index|
		text_fields = payment[:text_fields]

		if text_fields.present?
      text_fields.each do |key, value|  
        self.init_text_field << {
          field_configuration_id: key,
          parent_id: payment[:invoice_id],
          parent_type: 'Invoice',
          value_type: 'FieldText',
          value_id: nil,
          value: {
            value: value
          }
        }
      end
    end

	end
	self.init_text_field
end

def setup_drop_down_field
	self.init_drop_down_field = []
	self.payments_attributes.each_with_index do |payment, index|
		drop_down_fields = payment[:drop_down_fields]

		if drop_down_fields.present?
	    drop_down_fields.each do |key, value|  
	      self.init_drop_down_field << {
	        field_configuration_id: key,
	        parent_id: payment[:invoice_id],
	        parent_type: 'Invoice',
	        value_type: 'FieldDropDownSelection',
	        value_id: nil,
	        value: {
	          value_id: value
	        }
	      }
	    end
	  end

	end
	self.init_drop_down_field
end

def build_text_custom_fields
  # prepare and build field text so we can get the row id
  field_texts = []
  init_text_field.size.times do |i|
    # we added the import_id because MYSQl doesn't return the ids for the newly inserted batch
    # will use this later to capture the newly created field_texts from the import_ids
    field_texts << FieldText.new(value: self.import_id)
  end
  FieldText.import field_texts

  # capture the newly created fields texts
  newly_created_texts = FieldText.include_soft_deleted.where(value: self.import_id)

  # update its value
  original_values = init_text_field.pluck :value # original list of values
  original_values.each_with_index do |original_value, index|
    newly_created_texts[index].value = original_value[:value]
  end

  # now update the field text ids
  newly_created_texts.each_with_index do |text, index|
    init_text_field[index][:value_id] = text.id
  end

  # prepare and build the custom fields after updating the field text ids
  custom_fields = []
  init_text_field.each do |text|
    custom_fields << CustomField.new(value_id: text[:value_id],
                                     field_configuration_id: text[:field_configuration_id],
                                     parent_id: text[:parent_id],
                                     parent_type: text[:parent_type],
                                     value_type: text[:value_type],
                                     configured_field_value: text[:value][:value])
  end

  # bulk upsert field text with the new values and bulk insert the custom fields in one atomic op
  # ActiveRecord::Base.transaction do
    FieldText.import newly_created_texts.to_a, on_duplicate_key_update: [:value]
    CustomField.import custom_fields.to_a
  # end
end

def build_drop_down_custom_fields
  # prepare and build field drop_down so we can get the row id
  field_drop_down = []
  id = FieldDropDownItem.minimum :id
  dt = DateTime.now + 11.years
  value_id = FieldDropDownItem.minimum :id
  value_id = FieldDropDownItem.find(value_id).id
  init_drop_down_field.size.times do |i|
    # we added the import_id because MYSQl doesn't return the ids for the newly inserted batch
    # will use this later to capture the newly created field_drop_down from the import_ids
    field_drop_down << FieldDropDownSelection.new(value_id: value_id, created_at: dt)
  end
  FieldDropDownSelection.import field_drop_down

  # capture the newly created fields drop_downs
  newly_created_drop_downs = FieldDropDownSelection.include_soft_deleted.where(created_at: dt)

  # update its value
  original_values = init_drop_down_field.pluck :value # original list of values
  original_values.each_with_index do |original_value, index|
    newly_created_drop_downs[index].value_id = original_value[:value_id]
    newly_created_drop_downs[index].created_at = DateTime.now
  end

  # now update the field drop_down ids
  newly_created_drop_downs.each_with_index do |drop_down, index|
    init_drop_down_field[index][:value_id] = drop_down.id
    init_drop_down_field[index][:value_name] = drop_down.value.name
  end

  # prepare and build the custom fields after updating the field drop_down ids
  custom_fields = []
  init_drop_down_field.each do |drop_down|
    custom_fields << CustomField.new(value_id: drop_down[:value_id],
                                     field_configuration_id: drop_down[:field_configuration_id],
                                     parent_id: drop_down[:parent_id],
                                     parent_type: drop_down[:parent_type],
                                     value_type: drop_down[:value_type],
                                     configured_field_value: drop_down[:value_name])
  end

  # bulk upsert field drop_down with the new values and bulk insert the custom fields in one atomic op
  # ActiveRecord::Base.transaction do
    FieldDropDownSelection.import newly_created_drop_downs.to_a, on_duplicate_key_update: [:value_id, :created_at]
    CustomField.import custom_fields.to_a
  # end
end





private

def beneficiary_payment_params(payment)
  payment[:date] = payment[:invoice_date] || payment[:date]
  payment[:due_date] = payment[:invoice_due_date] || payment[:due_date]
  vendor_id = payment[:bank_account].account_owner_id
  bank_account_id = payment[:bank_account].id
  {
    name: payment[:name],
    vendor_id: vendor_id,
    bank_account_id: bank_account_id,
    category_id: payment[:category_id],
    cost_center_id: payment[:cost_center_id],
    department_id: payment[:department_id],
    sub_department_id: payment[:sub_department_id],
    company_id: self.company_id,
    gst_type_id: payment[:gst_type_id],
    tds_slab_id: payment[:tds_slab_id],
    payment_notification_users: payment[:payment_notification_users],
    status_id: BeneficiaryPaymentStatus.id_for(:pending),
    inclusive_of_taxes: StringUtils.to_bool(payment[:inclusive_of_taxes]),
    tax: payment[:tax],
    tax_rate_id: payment[:tax_rate_id],
    invoice_number: payment[:invoice_number],
    invoice_date: payment[:date],
    invoice_due_date: payment[:due_date],
    created_at: import_date
  	}
end

def payment_params(payment)
	payment[:date] = payment[:invoice_date] || payment[:date]
  payment[:due_date] = payment[:invoice_due_date] || payment[:due_date]
  bank_account = payment[:bank_account]
	{
      payment_type_id: PaymentType.id_for(:credit),
      application: "vp",
      receiving_user_type: bank_account.account_owner.class.name,
      receiving_user_id: bank_account.account_owner_id,
      initiating_user_type: "User",
      initiating_user_id: user.id,
      initiating_account_type: initiating_account&.class&.name,
      initiating_account_id: initiating_account&.id,
      receiving_account_type: "BankAccount",
      receiving_account_id: bank_account.id,
      payment_status_id: PaymentStatus.id_for(:pending_approval),
      payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
      payment_mode: self.payment_mode,
      transfer_mode_id: self.bank_payment_request.transfer_mode_id,
      reference_resource_type: self.bank_payment_request&.owner&.company&.feature_subscription&.bank_transaction_class&.name,
      note: payment[:note],
      # payment_notification_users: payment[:payment_notification_users],
      date: DateUtils.local_date,
      external_reference_id: payment[:external_reference_id],
      department_id: payment[:department_id],
      category_id: payment[:category_id],
      cost_center_id: payment[:cost_center_id],
      company_id: self.company_id,
      api_initiated: false,
      beneficiary_payment_id: beneficiary_payment&.id,
      # parent_type: set_payment_parent_type,
      # parent_id: set_payment_parent_id,
      custom_fields: payment[:custom_fields],
      text_fields: payment[:text_fields],
      drop_down_fields: payment[:drop_down_fields],
      payment_order_id: self.bank_payment_request.payment_order.id
	}

end

def invoice_params(payment)
	{
    category_id: payment[:category_id],
    cost_center_id: payment[:cost_center_id],
    inclusive_of_taxes: StringUtils.to_bool(payment[:inclusive_of_taxes]),
    gst_type_id: payment[:gst_type_id],
    tds_slab_id: payment[:tds_slab_id],
    # 
    # BENEFICIARY PAYMENTS WOULD NOW REQUIRE INVOICES
    # 
    invoice_number: payment[:invoice_number],
    date: payment[:date],
    due_date: payment[:due_date],
    tax: payment[:tax],
    invoice_status_id: InwardInvoiceStatus.id_for(:unpaid),
    invoice_type_id: InwardInvoiceType.id_for(:beneficiary),
    company_id: self.company_id
   }
end

def retrieve_initiating_account(company)
  case company&.feature_subscription&.bank_service_provider
  when "YES"
    initiating_account = user.company.yes_bank_company_account
  when "ICICI"
    initiating_account = user.company.icici_bank_company_account
  when "KOTAK"
    initiating_account = user.company.kotak_bank_company_account
  else
    initiating_account = user.company.yes_bank_company_account
  end
  initiating_account
end

def run_validations(elements)
	invalid_elements = []
	valid_elements = []
	semaphore = Mutex.new
	::Parallel.map(elements, in_threads: 0) do |element|
		semaphore.synchronize do
			if element.valid?
				valid_elements << element
			else
		    invalid_elements << element
	  	end
	  end
  end
  return valid_elements, invalid_elements  
end

def run_before_callbacks(elements)
  ::Parallel.map(elements, in_threads: 0) do |element|
  	ActiveRecord::Base.connection_pool.with_connection do
	    execute_callbacks(element, :before)
	  end
  end
end

def run_after_callbacks(elements)
  ::Parallel.map(elements, in_threads: 0) do |element|
  	ActiveRecord::Base.connection_pool.with_connection do
	    execute_callbacks(element, :after)
	  end
  end
end

def execute_callbacks(element, before_or_after)
  case before_or_after
    when :before
      element.run_callbacks(:save) { false }
      element.run_callbacks(:create) { false }
      element.run_callbacks(:update) { false }
    when :after
    	
      element.run_callbacks(:save) { true }
      element.run_callbacks(:create) { true }
      element.run_callbacks(:update) { true }
  end
end

def runner(batch, update=false)
	klass = batch.first.class
	if update
		klass.import batch, on_duplicate_key_update: batch.first.attributes.keys.map(&:to_sym)
	else
		
		klass.import batch
	end
	
	batch.map(&:reload) unless klass.name == BankAccount.class.name
end

def exec_statement(elements, validate_bulk=false, before_callbacks=false, after_callbacks=false, update=false)
  begin
    valid_details, invalid_details = run_validations elements if validate_bulk
    run_before_callbacks valid_details if before_callbacks
    valid_details = valid_details.present? ? valid_details : elements
    valid_details.each_slice(1000) do |batch|
      # execute statement
      runner batch, update
    end
    run_after_callbacks valid_details if after_callbacks
    true
  rescue => e
    puts "Error importing the bulk. Reason #{e.message}"
    false
  end
end

def execute_block(&blk)
	::Parallel.map(elements, in_threads: 0) do |element|
		element
	end
end


def strategy(klass)
	required_attributes = klass.validators.select { |v| v.is_a?(ActiveRecord::Validations::PresenceValidator) }.map(&:attributes).flatten
	formatted_attributes = klass.validators.select { |v| v.is_a?(ActiveModel::Validations::FormatValidator) }.map {|v| v.attributes.map {|m| {m => v.options[:with]}}.reduce({}, :merge)}.reduce({}, :merge)

	text_attributes = required_attributes.select {|attribute| [:string, :text].include? klass.columns_hash[attribute.to_s]&.type}
	integer_attributes = required_attributes.select {|attribute| [:integer, :decimal].include? klass.columns_hash[attribute.to_s]&.type}

	text_attributes = build_text_attributes klass, text_attributes, formatted_attributes
	integer_attributes = build_integer_attributes klass, integer_attributes, formatted_attributes

	params = text_attributes.merge(integer_attributes)
	params[:created_at] = import_date

	searchable_import_id_column = params.invert[import_id]
	searchable_import_number_column = params.invert[import_number]

	return klass.new(params), searchable_import_id_column, searchable_import_number_column
end

def build_text_attributes(klass, text_attributes, formatted_attributes)
	build_attributes = []
	text_attributes.each do |attribute|
		if formatted_attributes.include? attribute
			build_attributes << [attribute, formatted_attributes[attribute].gen]
		else
			build_attributes << [attribute, import_id]
		end
	end
	build_attributes.to_h
end

def build_integer_attributes(klass, integer_attributes, formatted_attributes)
	associations = klass.reflect_on_all_associations(:belongs_to)
	# association_foreign_keys = associations.map(&:foreign_key)
	association_foreign_keys = associations.map {|a| [a.foreign_key.to_sym, a.name]}.to_h

	foreign_keys = association_foreign_keys.keys & integer_attributes.map(&:to_sym)
	non_associations = integer_attributes - foreign_keys

	mapper = []
	if foreign_keys.present?
		foreign_keys.each do |key|
			associated_class = klass.reflect_on_association(association_foreign_keys[key].to_sym).klass
			id = associated_class.minimum :id
			value = associated_class.find(id).id
			mapper << [key, value]
		end
	end
	foreign_key_mapper = mapper.to_h

	default_integer = Array.new non_associations.size, import_number
	non_association_mapper = non_associations.zip(default_integer).to_h

	foreign_key_mapper.merge(non_association_mapper)
end
end