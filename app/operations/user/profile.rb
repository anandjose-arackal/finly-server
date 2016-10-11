class User::Profile < User::Base

  class User::Profile::ProfilePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :assigned_policies

    def init
      self.assigned_policies = user.policies
    end
  end


  def authorized_user_types
    [:employee]
  end

  def pre_validate
    unless user.present? and params.present?
      messages[:error] << "User or params not passed."
    end
  end

  def init

  end

  def authorize
    unless user.id == params[:user_id].to_i
      raise_unauthorized_exception
    end
  end

  def validate

  end

  def process

  end

  def success
    User::Profile::ProfilePresenter.new(user, params, messages)
  end

end