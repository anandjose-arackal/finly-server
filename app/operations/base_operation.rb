require 'hooks'
class BaseOperation
  include CallbackHandler, MathUtil, HasScope, OperationValidations
  # todo rename user to resource as User is a model and there can be other models such as AdminUser etc
  attr_accessor :user, :company, :params, :messages, :process_complete, :response

  # If initializers are over-ridden super() must be called in the inheriting class
  def initialize(user, params={})
    clear_messages
    self.user = user
    self.params = (ActionController::Parameters.new(params) or {})
  end

  def self.call(user, params={})
    self.new(user, params).run
  end

  # Applications
  def admin_panel?
    current_app == :ap || current_app == 'ap'
  end

  def vendor_payments?
    current_app == :vp || current_app == 'vp'
  end

  def expense_management?
    current_app == :em || current_app == 'em'
  end

  def funds_transfer?
    current_app == :ft || current_app == 'ft'
  end

  # Can be called as BaseOperations.(user, params) instead of BaseOperations.call(user, params)

  # Used to run the operation
  def run
    clear_messages
    validate_user_model
    return execute_failure if has_errors?
    authorize_subscriptions
    return execute_failure if has_errors?
    authorize_user authorized_user_types
    return execute_failure if has_errors?
    execute_function :pre_validate
    return execute_failure if has_errors?
    execute_function :pre_authorize
    return execute_failure if has_errors?
    execute_function :init
    return execute_failure if has_errors?
    execute_function :authorize
    return execute_failure if has_errors?
    execute_function :validate
    return execute_failure if has_errors?
    execute_function :subscribe
    return execute_failure if has_errors?
    if expense_management?
      execute_function :configure_expense_management
      return execute_failure if has_errors?
    elsif funds_transfer?
      execute_function :configure_disburse
      return execute_failure if has_errors?
    elsif vendor_payments?
      execute_function :configure_vendor_payment
      return execute_failure if has_errors?
    end
    execute_function :pre_process
    return execute_failure if has_errors?
    execute_function :process
    return execute_failure if has_errors?
    self.process_complete = true
    execute_function :post_process
    return execute_failure if has_errors?
    execute_function :retrieve
  end

  def user_model
    User
  end

  # Checks which type of user can access this operation
  def validate_user_model
    return unless user.present?
    required_user_model = user_model
    return unless required_user_model.present?
    required_user_model = [required_user_model] unless required_user_model.is_a?(Array)
    required_user_model.each do |req_model|
      if req_model.name == user.class.name
        return
      end
    end
    add_message :error, 'Invalid User. Access Denied'
  end

  # Defined all the required features user should be subscribed to to run this operation
  def subscription
    nil
  end

  # Authorizes the user based on his feature subscription
  def authorize_subscriptions
    required_subscription = subscription
    return if required_subscription.blank? or (user.blank? and company.blank?)
    allowed_subscriptions = nil
    if user.present?
      allowed_subscriptions = user.company.feature_subscription
    elsif company.present?
      allowed_subscriptions = company.feature_subscription
    end
    if allowed_subscriptions.present? and required_subscription.present?
      unless allowed_subscriptions.send(required_subscription)
        add_message :error, 'You have not subscribed for this feature'
        raise_unauthorized_exception
      end
    end
  end


  #   {
  #       pre_validate: {
  #           before: Personalizer::Process.new([:expense, :create], :pre_validate, params),
  #           after: Personalizer::Process.new([:expense, :create], :pre_validate, params)
  #       }
  #   }
  def personalizer
    {}
  end

  # Define the authorized user types for the action
  def authorized_user_types
    # [:employee, :manager, :finance_manager, :admin]
    nil
  end

  # Add all validations here for checking if the required data is present in params
  def pre_validate

  end

  def pre_authorize

  end

  # All objects which would be required for processing would be loaded here
  def init

  end

  def validate

  end

  # Verify if user has access to the given models
  def authorize

  end

  def pre_process

  end

  # For handling callbacks: Explanation with example in callback_handler.rb
  def subscribe

  end

  # Actual processing is handled here
  def process

  end

  # Any post process based events such as notifications, mailers is created here
  def post_process

  end

  def execute_post_operations(success)

  end

  def configure_expense_management

  end

  def configure_disburse

  end

  def configure_vendor_payment

  end

  # This would be sent as a return value
  def retrieve
    if self.response.present?
      response
    elsif success?
      execute_success
    else
      execute_failure
    end
  end

  def has_errors?
    self.messages.present? and (self.messages[:error].present? or self.messages[:failure].present?)
  end

  def processing?
    not self.process_complete
  end

  def success?
    self.process_complete and not has_errors?
  end

  def failure?
    self.process_complete and has_errors?
  end

  def current_app
    RequestStore.store[:current_app]
  end

  def current_device
    RequestStore.store[:current_device]
  end

  def current_user
    RequestStore.store[:current_user]
  end

  def authorized_scopes
    RequestStore.store[:authorized_scopes]
  end

  def current_company
    RequestStore.store[:current_company]
  end

  def current_request
    RequestStore.store[:request]
  end

  def request_params
    RequestStore.store[:params]
  end

  # Used to present the data to the UI
  class BaseOperation::BasePresenter
    include MathUtil, HasScope
    attr_accessor :user, :params, :messages, :config

    def initialize(user, params={}, messages={})
      self.config = {}
      self.user = user
      self.params = params
      self.messages = messages
      init
    end

    def init

    end

    def admin_view?
      is_view?(:admin)
    end

    def manager_view?
      is_view?(:manager) or is_view?(:reviewer)
    end

    def finance_view?
      is_view?(:finance) or is_view?(:finance_manager) or is_view?(:creditor)
    end

    def auditor_view?
      is_view?(:auditor)
    end

    def personal_view?
      is_view?(:employee) or is_view?(:personal) or is_view?(:initiator) or params[:view].blank?
    end

    def initiator_view?
      is_view?(:initiator)
    end

    def travel_manager_view?
      is_view?(:travel_manager)
    end

    def is_view?(type)
      type.present? and params.present? and params[:view].present? and (params[:view] == type.to_s or params[:view] == type.to_sym)
    end

    def success?
      false
    end

    def failure?
      false
    end

    def current_app
      RequestStore.store[:current_app]
    end

    def current_device
      RequestStore.store[:current_device]
    end

    def current_user
      RequestStore.store[:current_user]
    end

    def authorized_scopes
      RequestStore.store[:authorized_scopes]
    end

    def current_company
      RequestStore.store[:current_company]
    end

    def current_request
      RequestStore.store[:request]
    end

    def request_params
      RequestStore.store[:params]
    end

    class BaseOperation::BasePresenter::SuccessPresenter < BaseOperation::BasePresenter
      def success?
        true
      end

      def failure?
        false
      end
    end

    class BaseOperation::BasePresenter::FailurePresenter < BaseOperation::BasePresenter
      def success?
        false
      end

      def failure?
        true
      end
    end

  end

  protected
  def execute_success
    execute_post_operations(true)
    success
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(self.user, self.params, self.messages)
  end

  def execute_failure
    execute_post_operations(false)
    failure
  end

  def failure
    BaseOperation::BasePresenter::FailurePresenter.new(self.user, self.params, self.messages)
  end

  def authorize_user(user_types)
    return if user_types.blank?
    user_types = [user_types] unless user_types.is_a?(Array)
    if user.present?
      user_types.each do |user_type|
        if (user_type == :employee and user.employee?) or (user_type == :manager and user.manager?) or
            (user_type == :finance_manager and user.finance_manager?) or (user_type == :policy_admin and user.policy_admin?) or
            (user_type == :company_admin and user.company_admin?) or (user_type == :admin and user.admin?) or (user_type == :superadmin and user.superadmin?) or
            (user_type == :auditor and user.auditor?) or (user_type == :travel_manager && user.travel_manager?) or
            (user_type == :vendor_payments_admin && user.vendor_payments_admin?) or (user_type == :reviewer && user.vendor_payments_reviewer?) or (user_type == :creditor && user.vendor_payments_creditor?) or
            (user_type == :vendor_payments_admin && user.vendor_payments_admin?) or (user_type == :vendor_payments_reviewer && user.vendor_payments_reviewer?) or (user_type == :vendor_payments_creditor && user.vendor_payments_creditor?) or
            (user_type == :vendor_payments_initiator && user.vendor_payments_initiator?)
          return
        end
      end
    end
    raise_unauthorized_exception
  end

  def add_message(type, message)
    return if type.blank? or message.blank? or (type != :error and type != :failure and type != :success and type != :message and type != :notice)
    clear_messages if self.messages.blank?
    if message.is_a?(Array)
      messages[type].concat message
    elsif message.is_a?(String)
      messages[type] << message
    end
  end

  def raise_unauthorized_exception
    raise NotAuthorizedException
  end

  def admin_view?
    is_view?(:admin)
  end

  def manager_view?
    is_view?(:manager) or is_view?(:reviewer)
  end

  def finance_view?
    is_view?(:finance) or is_view? :finance_manager or is_view?(:creditor)
  end

  def travel_manager_view?
    is_view?(:travel_manager)
  end

  def auditor_view?
    is_view?(:auditor)
  end

  def personal_view?
    is_view?(:employee) or is_view?(:personal) or is_view?(:initiator) or params[:view].blank?
  end

  def initiator_view?
    is_view?(:initiator)
  end

  def is_view?(type)
    type.present? and params.present? and params[:view].present? and (params[:view] == type.to_s or params[:view] == type.to_sym)
  end

  def clear_messages
    self.messages = {error: [], failure: [], success: [], message: [], notice: []}
  end

  # Used for executing custom functions. All functions defined in personalizer would be executed here
  def execute_function(function)
    return unless function.present?

    personalizer_config = personalizer
    if personalizer_config.nil?
      personalizer_config = {}
    end

    # Run personalizer if present
    before_operation = personalizer_config&.dig(function, :before)
    before_operation&.run

    if before_operation&.has_errors?
      add_message :error, before_operation.messages[:error]
      return
    end

    result = self.send function
    if has_errors?
      return
    end
    # Run personalizer if present
    after_operation = personalizer_config&.dig(function, :after)
    after_operation&.run

    if after_operation&.has_errors?
      add_message :error, after_operation.messages[:error]
      return
    end

    # Return the result provided by the function
    result
  end

end
