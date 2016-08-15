class User::Team::Mapping::Update < User::Team::Mapping::Base
  attr_accessor :mapping, :update_params, :destroy?

  def pre_validate
    super
    unless params[:manager_id] or params['manager_id'] or params[:finance_manager_id] or params['finance_manager_id'] or
        params[:approves_to_id] or params['approves_to_id'] or params[:approves_finance_to_id] or
        params['approves_finance_to_id'] or (params['amount'] and params['currency_id'])
      errors << 'Nothing to update'
    end
    if params[:team_mapping_id].blank?
      errors << 'Team mapping not found'
    end
  end

  def init
    # if amount is left empty, remove the conditional manager params
    if params['amount'] and params['amount'].empty? and not self.mapping.default
      self.destroy? = true
      return
    end

    super

    self.mapping = mappings.with_id(id: params[:team_mapping_id]).first rescue nil
    return if self.mapping.blank?

    manager_id = params[:manager_id] or params['manager_id']
    finance_manager_id = params[:finance_manager_id] or params['finance_manager_id']
    approves_to_id = params[:approves_to_id] or params['approves_to_id']
    approves_finance_to_id = params[:approves_finance_to_id] or params['approves_finance_to_id']
    self.update_params= {manager_id: manager_id,
                         finance_manager_id: finance_manager_id,
                         approves_to_id: approves_to_id,
                         approves_finance_to_id: approves_finance_to_id}
    if not self.mapping.default and not params['amount'].blank? and params['amount'] != self.mapping.greater_than_amount_value and
        params['currency_id'] != self.mapping.greater_than_amount_currency_id
      self.update_params[:greater_than_amount_attributes] = {id: self.mapping.greater_than_amount_id, value: params['amount'],
                                                             currency_id: params['currency_id']}
    end
  end

  def authorize
    super
    if not destroy? and self.mapping.blank?
      errors << 'Configuration not found'
      raise_unauthorized_exception
    end
  end

  def validate
    super
    if not destroy? and self.update_params.blank?
      errors << 'Nothing to update'
    end
  end

  def process
    if self.destroy?
      destroy_operation = User::Team::Mapping::Destroy.new(user, params)
      destroy_operation.run
      errors << destroy_operation.errors if destroy_operation.has_errors?
    elsif not self.mapping.update_attributes(update_params)
      errors << self.mapping.errors.full_messages
    end
    self.response = self.mapping unless has_errors?
  end

end