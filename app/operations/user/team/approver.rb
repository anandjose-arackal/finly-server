class User::Team::Approver < User::Team::Base

  def pre_validate
    unless user.present?
      'User not found'
    end
    unless params[:type].present?
      'Manager type not found'
    end
    params[:type] = :approves_to_user if params[:type] == :approves_to
    params[:type] = :approves_finance_to_user if params[:type] == :approves_finance_to
    unless params[:type] == :manager or params[:type] == :finance_manager or
        params[:type] == :approves_to_user or params[:type] == :approves_finance_to_user
      errors << 'User type not valid'
    end
  end

  def init
    init_values
  end

  def authorize
    unless mappings.present?
      errors << 'Mapping not found'
    end
  end

  def process
    obj = self.mappings.send(params[:type]).policy(self.policy_id).amount(self.currency_id, self.amount_value).first.send(params[:type]) rescue nil
    return nil unless obj.present?
    self.response = obj
  end

end