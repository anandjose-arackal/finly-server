class Policy::Base < BaseOperation

  attr_accessor :policy

  class Policy::Base::PolicyPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :policy, :policies

    def init
      self.policy = params[:policy]
      self.policies = Policy::Index.(user, view: params[:view]).policies
    end
  end

  def pre_validate
    if user.blank?
      messages[:error] << 'User not found'
    end
  end

  def success
    Policy::Base::PolicyPresenter.new(user, {policy: policy}, messages)
  end

  def validate

  end

  def authorize
    unless policy
      raise_unauthorized_exception
    end
  end
end