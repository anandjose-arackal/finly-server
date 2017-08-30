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
        params[:type] == :approves_to or params[:type] == :approves_finance_to
      messages[:error] << 'User type not valid'
    end
  end

  def init
    init_values
    self.purpose_id = MappingPurpose.id_from_application_for(RequestStore.store[:current_app])
  end

  def authorize
    unless mappings.present?
      messages[:error] << 'Mapping not found'
    end
  end

  def process
    obj = self.mappings.send(params[:type]).policy(self.policy_id).with_purpose(self.purpose_id).amount(self.currency_id, self.amount_value).first.send(params[:type]) rescue nil
    return nil unless obj.present?
    self.response = obj
  end

  def retrieve
    self.response
  end

end