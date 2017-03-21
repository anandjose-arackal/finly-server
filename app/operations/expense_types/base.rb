class ExpenseTypes::Base < BaseOperation

  attr_accessor :expense_types_configuration, :update_params
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
      unless user.policy_admin?(parent_object) || user.company_admin?
        raise_unauthorized_exception
      end
    end
  end

  class ExpenseTypes::Base::ExpenseConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :expense_config_type

    def init
      self.expense_config_type = params[:expense_config_type]
    end
  end
end