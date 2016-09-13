class Policy::Base < BaseOperation

  attr_accessor :policy

  class Policy::Base::PolicyPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :policy

  end

  def pre_validate
    if user.blank?
      messages[:error] << "No user passed."
    end
  end

  def success
    policy
  end

  def validate

  end

  def authorize
    unless policy
      raise_unauthorized_exception
    end
  end
end