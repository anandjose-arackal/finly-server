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

def setup
	company = Company.find(73).name.split.first.parameterize.to_s
	date = DateTime.now.strftime('%b-%d-%a-%H-%M-%S').downcase
	rnd = SecureRandom.hex(11)
	IMPORT_ID = (company + "-" + date + "-" + rnd).freeze
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
		element.calculate_tax_and_amounts
		element.save
	end
end

def insert_beneficiary
	# TODO
	# convert array of hash to sql
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
	klass.import batch
end

def exec_statement(elements)
  begin
    valid_details, invalid_details = run_validations elements if @validate_bulk
    run_before_callbacks valid_details if @before_callbacks
    valid_details.each_slice(1000) do |batch|
      # execute statement
      runner batch
    end
    run_after_callbacks valid_details if @after_callbacks
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

