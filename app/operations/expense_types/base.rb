class ExpenseTypes::Base < BaseOperation

  attr_accessor :expense_types_configuration
  attr_accessor :parent_object, :parent_type

  def authorize
    unless parent_object
      raise_unauthorized_exception
    end

    # checking compatible user types for the various configurations
    if parent_object.is_a?(Company)
      unless user.company_admin?
        raise_unauthorized_exception
      end
    end
    if parent_object.is_a?(Policy)
      unless user.policy_admin?(configurable_object)
        raise_unauthorized_exception
      end
    end
  end
end