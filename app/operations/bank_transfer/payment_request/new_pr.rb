class BankTransfer::PaymentRequest::NewPr < BankTransfer::PaymentRequest::Base
	attr_accessor :vendor_id, :vendor, :requested_amount, :payment_mode, :bank_payment_request_params, :bank_payment_request,
					:payments_attributes, :options, :company_id, :execute, :payment_params,
					:name, :bank_account_number, :ifsc, :original_amount, :inclusive_of_taxes, :gst_type_id, :tax, :discount, :tds_slab_id,
					:category_id, :cost_center_id, :department_id, :invoice_number, :invoice_date, :due_date, :note

	def init
		self.vendor_id = params[:vendor_id]

		if self.vendor_id.present?
			self.vendor = YesBankVendor.find_by(id: self.vendor_id)
		end

		self.requested_amount = params[:amount]
		self.payment_mode = params[:payment_mode]

	
		params[:payments_attributes].each do |pa|
			if pa[:authorized]
				yes = YesBankVendor.find(pa[:vendor_id])
				ba = yes.bank_accounts.where(id: pa[:bank_account_id])
				pa[:bank_account_number] = ba.account_number
				pa[:ifsc] = ba.ifsc
			end
		end

	# self.payments_attributes = [{"authorized" => true,
	# 															"vendor_id" => "1",
	# 															"bank_account_id" => "2"
	# 															"name"=>"new one",
	# 														  "bank_account_number"=>"50000000000",
	# 														  "ifsc"=>"UTIB8888863",
	# 														  "original_amount"=> "1000",
	# 														  "inclusive_of_taxes"=>"y",
	# 														  "gst_type_id"=>"2",
	# 														  "tax"=>"5",
	# 														  "discount"=>"0",
	# 														  "tds_slab_id"=>"46",
	# 														  "category_id"=>"927",
	# 														  "cost_center_id"=>"28",
	# 														  "department_id"=>"41",
	# 														  "invoice_number"=>"no-9999",
	# 														  "invoice_date"=>"30-01-2019",
	# 														  "due_date"=>"31-01-2019",
	# 														  "note"=>"I dont know",
	# 														  "custom_fields"=>{}},

	# 														{"authorized" => false,
	# 															"vendor_id" => nil,
	# 															"bank_account_id" => nil
	# 															"name"=>"new one",
	# 														  "bank_account_number"=>"50000000000",
	# 														  "ifsc"=>"UTIB8888863",
	# 														  "original_amount"=> "1000",
	# 														  "inclusive_of_taxes"=>"y",
	# 														  "gst_type_id"=>"2",
	# 														  "tax"=>"5",
	# 														  "discount"=>"0",
	# 														  "tds_slab_id"=>"46",
	# 														  "category_id"=>"927",
	# 														  "cost_center_id"=>"28",
	# 														  "department_id"=>"41",
	# 														  "invoice_number"=>"no-9999",
	# 														  "invoice_date"=>"30-01-2019",
	# 														  "due_date"=>"31-01-2019",
	# 														  "note"=>"I dont know",
	# 														  "custom_fields"=>{}}]
		self.payments_attributes = params[:payments_attributes]
	end

	def process
	    # if the validation of the data is successful, it will create a payment order and
	    # asynchronously add payments to it one by one
	    self.bank_payment_request_params = parse_payment_order_data
	    puts "bank_payment_request params", bank_payment_request_params.inspect
	    self.bank_payment_request = BankPaymentRequest.create(self.bank_payment_request_params)
	    puts "bank_payment_request", bank_payment_request.inspect

		# BankTransfer::PaymentRequest::AddPaymentsBackground.call_async(user, {bank_payment_request_id: self.bank_payment_request.id, payments_attributes: order_details})


			puts "self.payments_attributes", self.payments_attributes.inspect
	    self.company_id = self.bank_payment_request.owner.company_id
	    self.user = self.bank_payment_request.owner
	    self.payment_mode = self.bank_payment_request.payment_mode
	    # here assign attributes to the existing bank payment request object which can be saved later
	    self.payment_params = []
	    self.payments_attributes.each do |payment|
	      bank_account = retrieve_bank_account(payment)
	      binding.pry
	      self.payment_params << {
	          payment_type_id: PaymentType.id_for(:credit),
	          application: "vp",
	          receiving_user_type: bank_account.account_owner.class.name,
	          receiving_user_id: bank_account.account_owner_id,
	          initiating_user_type: "User",
	          initiating_user_id: user.id,
	          initiating_account_type: YesBankCompanyAccount.name,
	          initiating_account_id: user.company.yes_bank_company_account.id,
	          receiving_account_type: "BankAccount",
	          receiving_account_id: bank_account.id,
	          payment_status_id: PaymentStatus.id_for(:pending_approval),
	          payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
	          purchase_order_id: payment[:purchase_order_id],
	          payment_mode: self.payment_mode,
	          amount_attributes: {
	              value: self.requested_amount,
	              currency_id: Currency.first.id
	          },
	          note: payment[:note],
	          date: DateUtils.local_date,
	          external_reference_id: payment[:external_reference_id],
	          department_id: payment[:department_id],
	          category_id: payment[:category_id],
	          company_id: user.company_id,
	          api_initiated: true,
	          invoice_attributes: {
	              category_id: payment[:category_id],
	              cost_center_id: payment[:cost_center_id],
	              inclusive_of_taxes: payment[:inclusive_of_taxes],
	              gst_type_id: payment[:gst_type_id],
	              tds_slab_id: payment[:tds_slab_id],
	              invoice_number: payment[:invoice_number],
	              date: payment[:invoice_date],
	              due_date: payment[:due_date],
	              tax: payment[:tax],
	              discount: payment[:discount],
	              invoice_status_id: InwardInvoiceStatus.id_for(:unpaid),
	              company_id: self.user.company_id,
	              original_amount_attributes: {
	                  value: self.requested_amount,
	                  currency_id: 1
	              }
	          },
	          custom_fields: payment[:custom_fields]
	      }
	    end


	    self.payment_params.each do |params|
	      custom_fields = params[:custom_fields]
	      params.delete(:custom_fields)
	      payment = self.bank_payment_request.payment_order.payments.build(params)
	      if payment.save
	        # perform the required calculations
	        InvoiceCalculationUtils.new.calculate_tax_and_discounts({}, payment)
	        payment.save
	        # now save the custom fields to the invoice
	        set_custom_fields_invoice(payment, {custom_fields: custom_fields}, true)
	      else
	      	puts "ERRORS", payment.errors.full_messages
	      end
	    end

	    # now once the payment request has been created and the payments saved, we can mark it as open
	    self.bank_payment_request.update(status_id: BankPaymentRequestStatus.id_for(:open))
	    self.bank_payment_request.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:pending_approval))
	    puts 'SUCCESSFUL!'

	end

	def success
	    params[:bank_payment_request_id] = self.bank_payment_request.id
	    BankTransfer::PaymentRequest::NewPr::SuccessPresenter.new(user, params, messages)
	end

	class BankTransfer::PaymentRequest::NewPr::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

	    attr_accessor :bank_payment_request_id

	    def init
	      self.bank_payment_request_id = params[:bank_payment_request_id]
	    end
	end


	private

	def parse_payment_order_data
		policy = user.enforce_policy_enabled? ? user.policies.non_default.first : user.policies.default.first
		payment_order_attributes = {
		    initiating_user_id: user.id,
		    payment_order_status_id: PaymentOrderStatus.id_for(:creation_in_progress),
		    company_id: user.company_id,
		    amount_requested_attributes: {
		        value: self.requested_amount,
		        currency_id: 1
		    },
		    payment_mode: self.payment_mode,
		    initiating_account_type: YesBankCompanyAccount.name,
		    receiving_account_type: BankAccount.name,
		    payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
		    application: "vp",
		    currency_id: Currency.first.id,
		    api_initiated: false
		}
		bpr_attributes = {
		    owner_id: user.id,
		    status_id: BankPaymentRequestStatus.id_for(:creation_in_progress),
		    controlling_user_id: user.id,
		    requested_amount_attributes: {
		        value: self.requested_amount,
		        currency_id: 1
		    },
		    beneficiary_type_id: 2,
		    policy_id: policy&.id,
		    payment_order_attributes: payment_order_attributes,
		    api_initiated: false
		}
		bpr_attributes
	end

	def set_custom_fields_invoice(payment, data, save)
    custom_fields = {custom_fields: data[:custom_fields]}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(payment.invoice, FieldParentType.id_for(:invoice), custom_fields)
  end

  def retrieve_bank_account(order_details)
    if order_details[:account_id].present?
      id = order_details[:account_id]
      ba = BankAccount.find_by(id: id)
      return ba
    else
      ba = BankAccount.non_deleted.find_by(account_number: order_details["bank_account_number"]&.strip, ifsc: order_details["ifsc"]&.strip,
                                           company_id: self.company_id, name: order_details["name"]&.strip,
                                           account_owner_type: YesBankVendor.name) # default for API initiations are 2, because they're always for vendors
      vendor = ba&.account_owner || YesBankVendor.find_or_create_by(name: order_details["name"], company_id: self.company_id)
      ba&.update(is_deleted: false) # i.e. if the bank account already exists, mark it as non deleted
      if ba.nil?
        ba = BankAccount.create(name: order_details["name"], account_number: order_details["bank_account_number"]&.strip, ifsc: order_details["ifsc"]&.strip,
                                account_owner: vendor, company_id: self.company_id, default_account: true)

      end
      return ba
    end
  end


end