# updates one particular mapping for a user
# params:
# team_mapping_id: id of the particular mapping that needs to be updated. Refers to an id of UserManagerMapping object
# manager_id: id of the manager for this mapping
# finance_manager_id: id of the finance manager for this mapping
# approves_to_id: id of the approves_to for this mapping
# approves_finance_to: id of the approves_finance_to for this mapping
# policy_id: optional if the mapping is associated with a policy
# user_id: user whose mapping params are being updated

class User::Team::Mappings::Update < User::Team::Mappings::Base
  attr_accessor :mapping, :update_params, :destroy_mapping

  def pre_validate
    if user.blank? or params.blank?
      errors << "No user or params passed."
    end
    if params[:currency_id].blank? # todo - will change once currencies are implemented
      params[:currency_id] = 1
    end
    unless params[:manager_id] or params['manager_id'] or params[:finance_manager_id] or params['finance_manager_id'] or
        params[:approves_to_id] or params['approves_to_id'] or params[:approves_finance_to_id] or
        params['approves_finance_to_id'] or (params[:amount] and params[:currency_id])
      errors << 'Nothing to update'
    end
    if params[:team_mapping_id].blank?
      errors << 'Team mapping not found'
    end
    if params[:amount] and params[:amount] < 0
      errors << "Cannot have a negative amount."
      return false
    end
  end

  def init
    super
    self.mapping = mappings.with_id(params[:team_mapping_id]).first rescue nil

    # if amount is left empty, remove the conditional manager params
    if params[:amount] and params[:amount].blank? and not self.mapping.default
      self.destroy_mapping = true
      return
    end

    return if self.mapping.blank?

    manager_id = params[:manager_id] or params['manager_id']
    finance_manager_id = params[:finance_manager_id] or params['finance_manager_id']
    approves_to_id = params[:approves_to_id] or params['approves_to_id']
    approves_finance_to_id = params[:approves_finance_to_id] or params['approves_finance_to_id']
    self.update_params= {manager_id: manager_id,
                         finance_manager_id: finance_manager_id,
                         approves_to_id: approves_to_id,
                         approves_finance_to_id: approves_finance_to_id}
    if not self.mapping.default and not params[:amount].blank? and (params[:amount] != self.mapping.greater_than_amount_value or params[:currency_id] != self.mapping.greater_than_amount_currency_id)
      self.update_params[:greater_than_amount_attributes] = {id: self.mapping.greater_than_amount_id, value: params[:amount],
                                                             currency_id: params[:currency_id]}
    end
  end

  def authorize
    super
    if not destroy_mapping and self.mapping.blank?
      errors << 'Configuration not found'
      raise_unauthorized_exception
    end
  end

  def validate
    super
    if not destroy_mapping and self.update_params.blank?
      errors << 'Nothing to update'
    end
  end

  def process
    if self.destroy_mapping
      destroy_operation = User::Team::Mapping::Destroy.new(user, params)
      destroy_operation.run
      errors << destroy_operation.errors if destroy_operation.has_errors?
    elsif not self.mapping.update_attributes(update_params)
      errors << self.mapping.errors.full_messages
    end
    self.response = self.mapping unless has_errors?
  end

  def retrieve
    if is_success?
      return mapping
    else
      return false
    end
  end

end