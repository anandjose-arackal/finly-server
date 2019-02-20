class BankTransfer::PaymentRequest::Review::ApproveBackground < BackgroundOperation

  attr_accessor :payment_requests, :options, :initiating_user, :processing_payment_requests

  def self.call(payment_request_ids, options = {})
    self.new.perform(payment_request_ids, options)
  end

  def perform(payment_request_ids, options, request_store_hash = nil)
    load_request_store request_store_hash
    if options.present? and options.is_a?(Hash)
      options = options.with_indifferent_access
    end
    self.payment_requests = BankPaymentRequest.where(id: payment_request_ids)
    self.options = options
    self.run
  end

  def initialize
    # self.payment_order = payment_order
    # self.options = options


    self.processing_payment_requests = []
  end

  def pre_validate

  end

  def init
    self.initiating_user = User.find_by(id: options[:initiating_user_id])
  end

  def validate
    # this will take all the payment requests that are not approvabe and
    # exclude them from the list of payment requests
    self.payment_requests.each do |payment_request|

      if payment_request.pending? && payment_request.get_reviewers.include?(initiating_user)
        self.processing_payment_requests.push(payment_requests)
      end

      # todo - Change status of other payment requests from pending to processing
    end

    if self.initiating_user.blank?
      add_message :error, "Initiating user has been returned as blank"
      return
    end
  end

  def process
    self.processing_payment_requests.each do |payment_request|
      # presenter = User::Team::Review::NextReviewer.(payment_request)
      # next_reviewer = presenter.user
      # next_reviewer_role_id = presenter.role_id
      # this returns the role under which this particular user is viewing the payment request
      # current_user_role = User::Team::Review::UserRole.(initiating_user, payment_request)
      # if next_reviewer.nil?
      #   payment_status = BankPaymentRequestStatus.id_for(:approved)
      # else
      #   payment_status = BankPaymentRequestStatus.id_for(:processing)
      # end
      # if payment_request.update status_id: payment_status,
      #                                controlling_user: next_reviewer,
      #                                controlling_user_role_id: next_reviewer_role_id
      #   payment_request.bank_payment_request_trails.create action_user: initiating_user,
      #                                                           action_user_role_id: current_user_role,
      #                                                           action_id: BankPaymentRequestTrailAction.id_for(:approve),
      #                                                           modified_user_id: next_reviewer&.id,
      #                                                           modified_user_role_id: next_reviewer_role_id
      # end

      # if payment_request.update status_id: payment_status,
      #                                controlling_user: next_reviewer,
      #                                controlling_user_role_id: next_reviewer_role_id
      #   payment_request.bank_payment_request_trails.create action_user: initiating_user,
      #                                                           action_user_role_id: current_user_role,
      #                                                           action_id: BankPaymentRequestTrailAction.id_for(:approve),
      #                                                           modified_user_id: next_reviewer&.id,
      #                                                           modified_user_role_id: next_reviewer_role_id
      # end

      # New Code
      params[:document] = payment_request
      params[:aasm_event] = 'approve'
      params[:violation_present] = false
      op = WorkflowManager::Base.(user, params)

      # unless op.success?
      #   add_message :error, op.messages[:error]
      #   return
      # end

      # self.workflow_output = op.workflow_output

      # generate comments for this particular action
      payment_request.comments.create user_id: initiating_user.id,
                                       action_id: BankPaymentRequestCommentAction.id_for(:approve)
    end
  end
end