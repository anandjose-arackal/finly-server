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
    end
  end

  def validate
    unless policy
      errors << "Policy not found"
    end
  end
end