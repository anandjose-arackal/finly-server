class BankTransfer::PaymentRequest::Review::BulkTakeControlBackground < BackgroundOperation

  attr_accessor :bank_payment_requests, :options, :initiating_user, :bank_payment_request_ids

  def self.call(bank_payment_request_ids, options = {})
    self.new.perform(bank_payment_request_ids, options)
  end

  def perform(bank_payment_request_ids, options, request_store_hash = nil)
    load_request_store request_store_hash
    if options.present? and options.is_a?(Hash)
      options = options.with_indifferent_access
    end
    self.bank_payment_requests = BankPaymentRequest.where(id: bank_payment_request_ids)
    self.bank_payment_request_ids = bank_payment_request_ids
    self.options = options
    self.run
  end

  def init
    self.initiating_user = User.find_by(id: options[:initiating_user_id])
  end

  def validate
    if self.initiating_user.blank?
      add_message :error, "Initiating user has been returned as blank"
      puts "initiating_user blank"
      return
    end
  end

  def process
    puts "RUNNING PROCESS"
    payment_status = BankPaymentRequestStatus.id_for(:processing)

    self.bank_payment_requests.each do |bank_payment_request|    
      # if bank_payment_request.update controlling_user: initiating_user,
      #                                controlling_for_user: bank_payment_request.controlling_user,
      #                                controlling_user_role_id: UserRole.id_for(:admin),
      #                                controlling_for_user_role_id: bank_payment_request.controlling_user_role_id,
      #                                status_id: payment_status
      # 
      # end

        parameters = {
            document: bank_payment_request,
            aasm_event: 'take_control'
        }

        op = WorkflowManager::Base.(initiating_user, parameters)

        if op.success?
          bank_payment_request.comments.create user_id: initiating_user.id,
                                         action_id: BankPaymentRequestCommentAction.id_for(:take_control),
                                         note: "BULK TAKE CONTROL by #{initiating_user.name}"
  
          bank_payment_request.bank_payment_request_trails.create action_user: initiating_user,
                                                                action_user_role_id: UserRole.id_for(:admin),
                                                                modified_user_id: bank_payment_request.controlling_for_user,
                                                                modified_user_role_id: bank_payment_request.controlling_for_user_role_id,
                                                                action_id: BankPaymentRequestTrailAction.id_for(:take_control)
        end        
    end

  end
end