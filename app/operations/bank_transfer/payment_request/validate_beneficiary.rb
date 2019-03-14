class BankTransfer::PaymentRequest::ValidateBeneficiary < BankTransfer::PaymentRequest::Base
	attr_accessor :order_details

	def init
		self.order_details = params[:payments_attributes]
	end

	def validate
	    self.validate_operation = BankTransfer::PaymentRequest::BulkValidateFileData.(user, {order_details: self.parsed_data})

	    if validate_operation.success?
	      self.requested_amount = validate_operation.requested_amount
	    else
	      self.contents = validate_operation.contents
	      self.headers = validate_operation.headers
	      add_message :error, "Some of the payments have errors, please check the downloaded file to resolve them"
	    end

	end
end