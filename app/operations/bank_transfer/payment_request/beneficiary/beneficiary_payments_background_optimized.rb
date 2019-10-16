# ██████╗ ███████╗ █████╗ ██████╗ ███╗   ███╗███████╗
# ██╔══██╗██╔════╝██╔══██╗██╔══██╗████╗ ████║██╔════╝
# ██████╔╝█████╗  ███████║██║  ██║██╔████╔██║█████╗  
# ██╔══██╗██╔══╝  ██╔══██║██║  ██║██║╚██╔╝██║██╔══╝  
# ██║  ██║███████╗██║  ██║██████╔╝██║ ╚═╝ ██║███████╗
# ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚══════╝
                                                   
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

def setup
	company = Company.find(73).name.split.first.parameterize.to_s
	date = DateTime.now.strftime('%b-%d-%a-%H-%M-%S').downcase
	rnd = SecureRandom.hex(11)
	@import_id = (company + "-" + date + "-" + rnd).freeze
	@import_number = rand(100_000_000..999_999_999)
	@import_date = DateTime.now + 11.years
end

def split_bank_accounts
	account_numbers = order_details.pluck :bank_account_number
	ifscs = order_details.pluck :ifsc
	account_names = order_details.pluck :bank_account_name

	bank_accounts = BankAccount.where(account_number: account_numbers, ifsc: ifscs, name: account_names, company_id: self.company_id, account_owner_type: YesBankVendor.name)
	
	account_numbers = bank_accounts.pluck :bank_account_number
	ifscs = bank_accounts.pluck :ifsc

	existing_accounts = order_details.select {|h| account_numbers.include?(h[:bank_account_number]) && ifscs.include?(h[:ifsc])}
	new_accounts = order_details - existing_accounts
end

def build_new_vendors
	vendors = []
	new_accounts.each do |account|
		business_name = account[:business_name] || account[:name]
		vendors << YesBankVendor.new(name: account[:name], company_id: self.company_id, business_name: business_name)
	end
	exec_statement vendors
	new_vendors = YesBankVendor.unscoped.where('import_id like ?', import_id).to_a
end

def build_new_bank_accounts
	bank_accounts = []
	valid_details.each do |account|
		business_name = account[:business_name] || account[:name]
		vendor = new_vendors.find do |vendor| 
			vendor if vendor.name == account[:name] && vendor.company_id == self.company_id && vendor.business_name == account[:business_name]
		end
		bank_accounts << BankAccount.new(name: account[:name],
																			account_number: account[:bank_account_number]&.strip,
																			ifsc: account[:ifsc]&.strip,
																			account_owner: vendor,
																			company_id: self.company_id,
																			default_account: true,
																			import_id: import_id)
	end
	exec_statement bank_accounts
	# BankAccount.import bank_accounts
end

def get_existing_bank_accounts
	account_numbers = order_details.pluck :account_number
	ifscs = order_details.pluck :ifsc
	bank_accounts = BankAccount.where(account_number: account_numbers, ifsc: ifscs, company_id: self.company_id, account_owner_type: YesBankVendor.name)
	bank_accounts.update_all is_deleted: false
	hash_records = Hash[bank_accounts.map {|ba| [ba.account_number, ba]}]

	order_details.each do |od|
		od[:bank_account] = hash_records[od[:account_number]]
	end
	order_details
end


def get_all_bank_accounts
	get_new_bank_accounts + get_existing_bank_accounts
end

def setup_beneficiary_payment
	beneficiary_details = []

	valid_details.each {|od| bp_params = beneficiary_payment_params(od); bp = BeneficiaryPayment.new(bp_params); beneficiary_details << bp}

	BeneficiaryPayment.import beneficiary_details

	beneficiary_payments = BeneficiaryPayment.unscoped.where('import_id like ?', import_id).to_a

	valid_details.each_with_index do |vd, ix| 
		beneficiary_payments[ix].original_amount = Amount.new(value: vd[:original_amount], currency_id: 1)
		beneficiary_payments[ix].advance_amount = Amount.new(value: vd[:advance_amount], currency_id: 1)
	end

	::Parallel.map(beneficiary_payments, in_threads: 4) do |element|
		element.calculate_tax_and_amount
		element.save
	end
end

def insert_beneficiary
	# TODO
	# convert array of hash to sql
end





def build_amounts
	amounts = []
	(order_details.size * 3).times do |i|
		amounts << Amount.new(value: import_id, currency_id: 1)
	end

	Amount.import amounts

	amounts = Amount.unscoped.where(value: import_id, created_at: import_date)

	payment_amounts, original_amounts, advance_amounts = amounts.in_groups_of(3, false)

	order_details.each_with_index do |order, index|
		payment_amounts[index] = order[:original_amount] 
		original_amounts[index] = order[:original_amount] 
		advance_amounts[index] = order[:advance_amount] 
	end

	klass, import_id_column, import_number_column = strategy(Invoice)

	invoices = Array.new(order_details.size, klass)
	Invoice.import invoices

	if import_id_column.present? or import_number_column.present?
		kolumn, kolumn_value = import_id_column.present? ? [import_id_column, import_id] : [import_number_column, import_number]
		invoices = Invoice.unscoped.where(kolumn => kolumn_value, :created_at => import_date)
	else
		invoices = Invoice.unscoped.where(created_at: import_date)
	end

	invoice_params.each_with_index do |params, index|
		# params = invoices[index].attributes.with_indifferent_access
		params[:original_amount_id] = original_amounts[index].id
		params[:advance_amount_id] = advance_amounts[index].id
		params[:created_at] = DateTime.now
		invoices[index].assign_attributes params
	end

	Invoice.import invoices, on_duplicate_key_update: invoices.first.attributes.keys.map(&:to_sym)

	klass, import_id_column, import_number_column = strategy(Payment)
	payments = Array.new(order_details.size, klass)
	Payment.import payments

	if import_id_column.present? or import_number_column.present?
		kolumn, kolumn_value = import_id_column.present? ? [import_id_column, import_id] : [import_number_column, import_number]
		payments = Payment.unscoped.where(kolumn => kolumn_value, :created_at => import_date)
	else
		payments = Payment.unscoped.where(created_at: import_date)
	end

	payment_params.each_with_index do |params, index|
		params[:amount_id] = payment_amounts[index].id
		params[:invoice_id] = invoices[index].id
		params[:created_at] = DateTime.now
		params[:beneficiary_payment_id] = beneficiary_payments[index].id
		payments[index].assign_attributes params
	end

	Payment.import payments, on_duplicate_key_update: payments.first.attributes.keys.map(&:to_sym)

end





private

def beneficiary_payment_params(payment)
  payment[:date] = payment[:invoice_date] || payment[:date]
  payment[:due_date] = payment[:invoice_due_date] || payment[:due_date]
  vendor_id = payment[:bank_account].vendor_id
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
    original_amount_attributes: {
            value: payment[:original_amount],
            currency_id: Currency.first.id
    },
    advance_amount_attributes: {
            value: payment[:advance_amount],
            currency_id: Currency.first.id
    },
    invoice_number: payment[:invoice_number],
    invoice_date: payment[:date],
    invoice_due_date: payment[:due_date],
    import_id: import_id
  }
end

def payment_params(payment)
	payment[:date] = payment[:invoice_date] || payment[:date]
  payment[:due_date] = payment[:invoice_due_date] || payment[:due_date]
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
    amount_attributes: {
        value: payment[:original_amount],
        currency_id: Currency.first.id
    },
    note: payment[:note],
    # payment_notification_users: payment[:payment_notification_users],
    date: DateUtils.local_date,
    external_reference_id: payment[:external_reference_id],
    department_id: payment[:department_id],
    category_id: payment[:category_id],
    cost_center_id: payment[:cost_center_id],
    company_id: user.company_id,
    api_initiated: false,
    beneficiary_payment_id: beneficiary_payment&.id,
    parent_type: set_payment_parent_type,
    parent_id: set_payment_parent_id,
    custom_fields: payment[:custom_fields],
    text_fields: payment[:text_fields],
    drop_down_fields: payment[:drop_down_fields]
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
    company_id: self.user.company_id,
   }
end

def run_validations(elements)
	invalid_elements = []
	valid_elements = []
	semaphore = Mutex.new
	::Parallel.map(elements, in_threads: 4) do |element|
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
  ::Parallel.map(elements, in_threads: 4) do |element|
  	ActiveRecord::Base.connection_pool.with_connection do
	    execute_callbacks(element, :before)
	  end
  end
end

def run_after_callbacks(elements)
  ::Parallel.map(elements, in_threads: 4) do |element|
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

def runner(batch)
	klass = batch.first.class
	klass.import batch
end

def exec_statement(elements, validate_bulk=false, before_callbacks=false, after_callbacks=false)
  begin
    valid_details, invalid_details = run_validations elements if validate_bulk
    run_before_callbacks valid_details if before_callbacks
    valid_details.each_slice(1000) do |batch|
      # execute statement
      runner batch
    end
    run_after_callbacks valid_details if after_callbacks
    true
  rescue => e
    puts "Error importing the bulk. Reason #{e.message}"
    false
  end
end

def execute_block(&blk)
	::Parallel.map(elements, in_threads: 4) do |element|
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