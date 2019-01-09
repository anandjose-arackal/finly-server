class User::Team::Approver < User::Team::Base

  attr_accessor :purpose_id

  def pre_validate
    unless user.present?
      'User not found'
    end
    unless params[:type].present?
      'Manager type not found'
    end
    unless params[:type] == :manager or params[:type] == :finance_manager or
        params[:type] == :approves_to or params[:type] == :approves_finance_to or
        params[:type] == :travel_manager
      messages[:error] << 'User type not valid'
    end
  end

  def init
    init_values
    self.purpose_id = Purpose.id_from_application_for(RequestStore.store[:current_app])
  end

  def authorize
    unless mappings.present?
      messages[:error] << 'Mapping not found'
    end
  end

  def process
    mapping = self.mappings.send(params[:type]).policy(self.policy_id).with_purpose(self.purpose_id).amount(self.currency_id, self.amount_value).first rescue nil
    
    # Handling condition where approver is required only if violations exists
    unless params[:has_violations] or params[:report].blank?
      case params[:type]
      when :manager
        mapping = nil if mapping&.manager_violation_only
      when :finance_manager
        mapping = nil if mapping&.finance_violation_only
      when :approves_to
        mapping = nil if mapping&.approves_to_violation_only
      when :approves_finance_to
        mapping = nil if mapping&.approves_finance_to_violation_only
      else
        # Nothing
      end
    end

    obj = mapping&.send(params[:type]) rescue nil

    return nil unless obj.present?
    # first checking if this user has a delegated user
    # if so, return delegate, otherwise return regular
    if obj.is_a?(User) && obj.user_delegate.present? && obj.delegation_enabled
      self.response = obj.user_delegate
      return
    end
    self.response = obj
  end

  def retrieve
    self.response
  end

end