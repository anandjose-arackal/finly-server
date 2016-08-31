class User::Team::Mappings::Create < User::Team::Mappings::Base
  attr_accessor :create_params, :amount_value, :currency_id

  def pre_validate
    super
    unless (params[:amount].present? || params['amount'].present?) and
        (params[:currency_id].present? || params['currency_id'].present?)
      errors << 'Greater than amount not defined'
    end
  end

  def init
    super()
    self.amount_value = params[:amount] || params['amount']
    self.currency_id = params[:currency_id] || params['currency_id']
    unless currency_id
      self.currency_id = 1
    end
    self.create_params = {user_id: params[:user_id], manager_id: (params[:manager_id] or params['manager_id']),
                          finance_manager_id: (params[:finance_manager_id] or params['finance_manager_id']),
                          approves_to_id: (params[:approves_to_id] or params['approves_to_id']),
                          approves_finance_to_id: (params[:approves_finance_to_id] or params['approves_finance_to_id']),
                          policy_id: params[:policy_id], greater_than_amount_attributes: {value: amount_value, currency_id: currency_id}}
  end

  def authorize

  end

  def validate
    super
    # in create, if there is already a manager assigned for this exact value, throw an error
    mapping = mappings.exact_amount(self.currency_id, self.amount_value) if mappings
    return unless mapping.present?
    if create_params[:manager_id].present? and mapping.manager.present? and
        create_params[:manager_id].to_s != mapping.manager_id.to_s
      errors << 'Another manager is already configured for the given amount'
    end
    if create_params[:finance_manager_id].present? and mapping.finance_manager.present? and
        create_params[:finance_manager_id].to_s != mapping.finance_manager_id.to_s
      errors << 'Another finance manager is already configured for the given amount'
    end
    if create_params[:approves_to_id].present? and mapping.approves_to.present? and
        create_params[:approves_to_id].to_s != mapping.approves_to.to_s
      errors << 'Another approves to manager is already configured for the given amount'
    end
    if create_params[:approves_finance_to_id].present? and mapping.approves_finance_to.present? and
        create_params[:approves_finance_to_id].to_s != mapping.approves_finance_to.to_s
      errors << 'Another approves finance to manager is already configured for the given amount'
    end
    if self.create_params.blank?
      errors << 'Nothing to update'
    end
  end

  def process
    mapping = self.mappings.build(create_params)
    unless mapping.save
      errors << mapping.errors.full_messages
    end
    self.response = mapping unless has_errors?
  end

end