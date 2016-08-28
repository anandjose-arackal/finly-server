class Policy::Base < BaseOperation

  attr_accessor :policy

  def pre_validate
    if user.blank?
      errors << "No user passed."
    end
  end

  def retrieve
    if is_success?
      return policy
    else
      return false
    end
  end

  def validate

  end

  def authorize
    unless policy
      raise_unauthorized_exception
    end
  end
end