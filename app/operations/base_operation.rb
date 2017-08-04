require 'hooks'
class BaseOperation
  include CallbackHandler, MathUtil, HasScope
  # todo rename user to resource as User is a model and there can be other models such as AdminUser etc
  attr_accessor :user, :company, :params, :messages, :process_complete, :response, :current_app

  # If initializers are over-ridden super() must be called in the inheriting class
  def initialize(user, params={})
    clear_messages
    # self.current_app = params[:current_app]
    self.user = user
    self.params = (ActionController::Parameters.new(params) or {})
  end

  def self.call(user, params={})
    self.new(user, params).run
  end

  # Applications
  def admin_panel?
    current_app == :ap ? true : false
  end

  def vendor_payments?
    current_app == :vp ? true : false
  end

  def expense_management?
    current_app == :em ? true : false
  end

  def funds_transfer?
    current_app == :ft ? true : false
  end

  # Can be called as BaseOperations.(user, params) instead of BaseOperations.call(user, params)

  # Used to run the operation
  def run
    clear_messages
    validate_user_model
    return failure if has_errors?
    authorize_subscriptions
    return failure if has_errors?
    authorize_user authorized_user_types
    return failure if has_errors?
    pre_validate
    return failure if has_errors?
    pre_authorize
    return failure if has_errors?
    init
    return failure if has_errors?
    authorize
    return failure if has_errors?
    validate
    return failure if has_errors?
    subscribe
    return failure if has_errors?
    configure_expense_management
    return failure if has_errors?
    configure_disburse
    return failure if has_errors?
    pre_process
    return failure if has_errors?
    process
    return failure if has_errors?
    self.process_complete = true
    post_process
    return failure if has_errors?
    retrieve
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
      if req_model == user.class
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

  def configure_expense_management

  end

  def configure_disburse

  end

  # This would be sent as a return value
  def retrieve
    if self.response.present?
      response
    elsif success?
      success
    else
      failure
    end
  end

  def has_errors?
    self.messages[:error].present? or self.messages[:failure].present?
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
      is_view?(:manager)
    end

    def finance_view?
      is_view?(:finance) or is_view?(:finance_manager)
    end

    def auditor_view?
      is_view?(:auditor)
    end

    def personal_view?
      is_view?(:employee) or is_view?(:personal) or params[:view].blank?
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
  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(self.user, self.params, self.messages)
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
            (user_type == :finance_manager and user.finance_manager?) or(user_type == :policy_admin and user.policy_admin?) or
            (user_type == :company_admin and user.company_admin?) or (user_type == :admin and user.admin?) or (user_type == :superadmin and user.superadmin?)
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
    is_view?(:manager)
  end

  def finance_view?
    is_view?(:finance) or is_view? :finance_manager
  end

  def auditor_view?
    is_view?(:auditor)
  end

  def personal_view?
    is_view?(:employee) or is_view?(:personal) or params[:view].blank?
  end

  def is_view?(type)
    type.present? and params.present? and params[:view].present? and (params[:view] == type.to_s or params[:view] == type.to_sym)
  end

  def is_expense_management_panel?
    !is_disburse_panel?
  end

  def is_disburse_panel?
    !!params&.dig(:request)&.referrer&.include?('disburse')
  end

  def clear_messages
    self.messages = {error: [], failure: [], success: [], message: [], notice: []}
  end

end
