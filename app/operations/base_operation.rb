class BaseOperation
  attr_accessor :user, :params, :errors, :process_complete, :response

  # If initializers are over-ridden super() must be called in the inheriting class
  def initialize(user, params={})
    self.errors = []
    self.user = user
    self.params = (params or {})
  end

  # Can be called as BaseOperations.(user, params) instead of BaseOperations.call(user, params)
  def self.call(user, params={})
    self.new(user, params).run
  end

  # Used to run the operation
  def run
    errors.clear
    authorize_user authorized_user_types
    return if has_errors?
    pre_validate
    return if has_errors?
    pre_authorize
    return if has_errors?
    init
    return if has_errors?
    authorize
    return if has_errors?
    validate
    return if has_errors?
    process
    return if has_errors?
    self.process_complete = true
    post_process
    return if has_errors?
    retrieve
  end

  # Define the authorized user types for the action
  def authorized_user_types
    # [:employee, :manager, :finance_manager, :admin]
    nil
  end

  # Add all validations come here for checking if the required data is present in params
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

  # Actual processing is handled here
  def process

  end

  # Any post process based events such as notifications, mailers is created here
  def post_process

  end

  # This would be sent as a return value
  def retrieve
    if self.response.present?
      response
    elsif is_success?
      success
    else
      failure
    end
  end

  def has_errors?
    self.errors.present?
  end

  def processing?
    not self.process_complete
  end

  def is_success?
    self.process_complete and not errors.present?
  end

  def is_failure?
    self.process_complete and errors.present?
  end

  # Used to present the data to the UI
  class BaseOperation::BasePresenter

  end

  protected
  def success
    true
  end

  def failure
    false
  end

  def authorize_user(user_types)
    return if user_types.blank?
    user_types = [user_types] unless user_types.is_a?(Array)

    if user.present?
      user_types.each do |user_type|
        if (user_type == :employee and user.employee?) or (user_type == :manager and user.manager?) or
            (user_type == :finance_manager and user.finance_manager?) or (user_type == :admin and user.admin?)
          return
        end
      end
    end
    raise_unauthorized_exception
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
    is_view?(:finance)
  end

  def auditor_view?
    is_view?(:auditor)
  end

  def personal_view?
    is_view?(:employee) or is_view?(:personal)
  end

  def is_view?(type)
    type.present? and params.present? and params[:view].present? and (params[:view] == type.to_s or params[:view] == type.to_sym)
  end

end
