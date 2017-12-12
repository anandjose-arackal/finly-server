class BankTransfer::PaymentRequest::Review::ApproveBackground < BackgroundOperation

  attr_accessor :payment_requests, :options, :initiating_user

  def self.call(payment_request_ids, options = {})
    self.new.perform(payment_request_ids, options)
  end

  def self.call_async(payment_request_ids, options = {})
    # define the operation to accordingly run the operation in the background
    self.perform_async(payment_request_ids, options)
  end

  def perform(payment_request_ids, options)
    if options.present? and options.is_a?(Hash)
      options = options.with_indifferent_access
    end
    self.payment_requests = BankPaymentRequest.unscoped.where(id: payment_request_ids)
    self.options = options
    self.run
  end

  def perform_async(payment_request_ids, options)
    # in case the object is passed directly instead of an id
    # calls the Sidekiq::Worker method
    super(payment_request_ids, options)
  end

  def initialize
    # self.payment_order = payment_order
    # self.options = options
  end

  def pre_validate

  end

  def init
    self.initiating_user = User.find_by(id: options[:initiating_user])
  end

  def validate
    # this will take all the payment requests that are not approvabe and
    # exclude them from the list of payment requests
    self.payment_requests.each do |payment_request|
      valid = true
      unless payment_request.pending?
        valid = false
      end
      unless payment_request.controlling_user_id == self.initiating_user.id
        valid = false
      end
      unless valid
        self.payment_requests.reject! { |pr| pr.id == payment_request.id }
      end
    end
  end

  def process
    self.payment_requests.each do |payment_request|
      presenter = User::Team::Review::NextReviewer.(payment_request)
      next_reviewer = presenter.user
      next_reviewer_role_id = presenter.role_id
      # this returns the role under which this particular user is viewing the payment request
      current_user_role = User::Team::Review::UserRole.(user, payment_request)
      if next_reviewer.nil?
        payment_status = BankPaymentRequestStatus.id_for(:approved)
      else
        payment_status = BankPaymentRequestStatus.id_for(:processing)
      end
      if payment_request.update status_id: payment_status,
                                     controlling_user: next_reviewer,
                                     controlling_user_role_id: next_reviewer_role_id
        payment_request.bank_payment_request_trails.create action_user: user,
                                                                action_user_role_id: current_user_role,
                                                                action_id: BankPaymentRequestTrailAction.id_for(:approve),
                                                                modified_user_id: next_reviewer&.id,
                                                                modified_user_role_id: next_reviewer_role_id
        return true
      end
    end
  end
end