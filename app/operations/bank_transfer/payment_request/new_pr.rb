# This creates a new bankpaymentrequest/payment ticket
# This handles payments to beneficiries, unauthorized/authorized

# TODO
# create individual payments in the background
# handle all type of validations
# reuse existing bulkvalidation

class BankTransfer::PaymentRequest::NewPr < BankTransfer::PaymentRequest::Base
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
	    if params[:payments_attributes].blank?
	      add_message :error, 'Vendor params not sent for processing.'
	      return
	    end
	  end

	def init
		
		self.payment_mode = params[:payment_mode]
	
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
	      add_message :error, self.issues
	    end

	end

	def process
	    # if the validation of the data is successful, it will create a payment order and
	    # asynchronously add payments to it one by one
	    self.bank_payment_request_params = parse_payment_order_data
	    self.bank_payment_request = BankPaymentRequest.create(self.bank_payment_request_params)
		op = BankTransfer::PaymentRequest::AddPaymentsBackground.call_async(user, {bank_payment_request_id: self.bank_payment_request.id, payments_attributes: self.validate_operation.order_details})

	end

	def success
	    params[:bank_payment_request_id] = self.bank_payment_request.id
	    BankTransfer::PaymentRequest::NewPr::SuccessPresenter.new(user, params, messages)
	end

	def failure
	    params[:issues] = self.issues
	    BankTransfer::PaymentRequest::NewPr::FailurePresenter.new(user, params, messages)
	end

	class BankTransfer::PaymentRequest::NewPr::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

	    attr_accessor :bank_payment_request_id

	    def init
	      self.bank_payment_request_id = params[:bank_payment_request_id]
	    end
	end

	class BankTransfer::PaymentRequest::NewPr::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter

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
end