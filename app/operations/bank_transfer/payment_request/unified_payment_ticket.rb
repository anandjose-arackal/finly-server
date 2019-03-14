# This creates a new bankpaymentrequest/payment ticket
# without using excel sheet
# Part of new payment concept
# User can create multiple payments
# This handles payments to beneficiries, unauthorized/authorized

# TODO
# create individual payments in the background DONE
# handle all type of validations DONE
# reuse existing bulkvalidation DONE

class BankTransfer::PaymentRequest::UnifiedPaymentTicket < BankTransfer::PaymentRequest::Base
	attr_accessor :vendor_id, :vendor, :total_amount, :payment_mode, :bank_payment_request_params, :bank_payment_request,
					:payments_attributes, :options, :company_id, :execute, :payment_params,
					:name, :bank_account_number, :ifsc, :original_amount, :inclusive_of_taxes, :gst_type_id, :tax, :discount, :tds_slab_id,
					:category_id, :cost_center_id, :department_id, :invoice_number, :invoice_date, :due_date, :note,
					:contents, :headers, :issues, :validate_operation

	def pre_validate
	    if user.blank?
	      add_message :error, 'User not found'
	      return
	    end
	    if params.blank?
	      add_message :error, 'No params sent at all.'
	      return
	    end
	    if params[:ticket_type].blank?
	    	add_message :error, 'WTF, tell me what type of ticket you want to create?'
	    	return
	    end
	   
	    unless ['invoice', 'po_advance', 'beneficiary', 'bulk_beneficiary'].include? params[:ticket_type].downcase
	    	add_message :error, "Unknown ticket type format"
	    	return
	    end

	    # Based on the ticket type, see if relevent attributes are present or not
	    ca = check_attribute(params)
	    if ca[:obj].blank?
	      add_message :error, ca[:err]
	      return
	    end	
	end

	

	def init
		
		self.payment_mode = params[:payment_mode]

		prepare_attribute(params)	
		
	end

	def validate
	    if payments_attributes.blank?
	      add_message :error, 'Nothing to process'
	      return
	    end

	    self.validate_operation = BankTransfer::PaymentRequest::BulkValidateFileData.(user, {order_details: self.payments_attributes})

	    if validate_operation.success?
	    	# total of all individual payments
	    	# to be set in bpr
	      self.total_amount = validate_operation.requested_amount
	    else
	      self.contents = validate_operation.contents
	      self.headers = validate_operation.headers
	      self.issues = validate_operation.issues
	      add_message :error, "Some of the vendor data were found to have issues. Please correct them."
	    end

	end

	def process
	    # if the validation of the data is successful, it will create a payment order and
	    # asynchronously add payments to it one by one
	    self.bank_payment_request_params = parse_payment_order_data
	    self.bank_payment_request = BankPaymentRequest.create(self.bank_payment_request_params)

	    # Delegate payment creation to the background operation
		BankTransfer::PaymentRequest::AddPaymentsBackground.call_async(user, {bank_payment_request_id: self.bank_payment_request.id, payments_attributes: self.validate_operation.order_details})

	end

	def success
	    params[:bank_payment_request_id] = self.bank_payment_request.id
	    BankTransfer::PaymentRequest::UnifiedPaymentTicket::SuccessPresenter.new(user, params, messages)
	end

	def failure
	    params[:issues] = self.issues
	    BankTransfer::PaymentRequest::UnifiedPaymentTicket::FailurePresenter.new(user, params, messages)
	end

	class BankTransfer::PaymentRequest::UnifiedPaymentTicket::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

	    attr_accessor :bank_payment_request_id

	    def init
	      self.bank_payment_request_id = params[:bank_payment_request_id]
	    end
	end

	class BankTransfer::PaymentRequest::UnifiedPaymentTicket::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter

	    attr_accessor :issues

	    def init
	      self.issues = params[:issues]
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
		        value: self.total_amount,
		        currency_id: 1
		    },
		    payment_mode: self.payment_mode,
		    scheduled_at: params[:scheduled_at],
		    # payment_mode: params[:payment_mode],
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
		        value: self.total_amount,
		        currency_id: 1
		    },
		    beneficiary_type_id: 2,
		    policy_id: policy&.id,
		    payment_order_attributes: payment_order_attributes,
		    api_initiated: false
		}
		bpr_attributes
	end

	def check_attribute(params)
		case params[:ticket_type].downcase
		when 'invoice'
			{obj: params[:invoice_attributes], err:'Invoice params not sent for processing.'}
		when 'po_advance'
			{obj: params[:po_advance_attributes], err:'Purchase Order params not sent for processing.'}
		when 'beneficiary'
			{obj: params[:payments_attributes], err:'Vendor params not sent for processing.'}
		when 'bulk_beneficiary'
			{obj: params[:payments_attributes], err:'Vendor params not sent for processing.'}
		end
	end

	def prepare_attribute(params)
		case params[:ticket_type].downcase
		when 'invoice'
			for_invoice(params)
		when 'po_advance'
			for_po_advance(params)
		when 'beneficiary'
			for_beneficiary(params)
		when 'bulk_beneficiary'
			for_bulk_beneficiary(params)
		end
	end

	def for_invoice(params)
	end

	def for_po_advance(params)		
	end

	def for_beneficiary(params)
		params[:payments_attributes].each do |pa|
			if pa[:authorized]
				yes = YesBankVendor.find(pa[:vendor_id])
				ba = yes.bank_accounts.where(id: pa[:bank_account_id])
				pa[:bank_account_number] = ba.pluck(:account_number).first
				pa[:ifsc] = ba.pluck(:ifsc).first
			end
		end
		self.payments_attributes = params[:payments_attributes]
	end

	def for_bulk_beneficiary(params)		
	end
			
			
			
			
end