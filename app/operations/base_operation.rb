class BaseOperation
  attr_accessor :user, :params, :errors, :process_complete

  def initialize(user, params={})
    self.errors = []
    self.user = user
    self.params = params
  end

  def self.call(user, params={})
    self.new(user, params).run
  end

  def run
    errors.clear
    authorize_user authorized_user_types
    return if has_errors?
    validate
    return if has_errors?
    init
    return if has_errors?
    authorize
    return if has_errors?
    process
    return if has_errors?
    self.process_complete = true
    post_process
    return if has_errors?
    retrieve
  end

  def authorized_user_types
    nil
  end

  def validate

  end

  def init

  end

  def authorize

  end

  def process

  end

  def post_process

  end

  def retrieve
    success
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

end
