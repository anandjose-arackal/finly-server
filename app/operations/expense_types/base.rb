class ExpenseTypes::Base < BaseOperation


  attr_accessor :expense_types_configuration

  def authorize
    unless configurable_object
      raise_unauthorized_exception
    end

    # checking compatible user types for the various configurations
    if configurable_object.is_a?(Company)
      unless user.company_admin?
        raise_unauthorized_exception
      end
    end
    if configurable_object.is_a?(Policy)
      unless user.policy_admin?(configurable_object)
        raise_unauthorized_exception
      end
    end
  end
end