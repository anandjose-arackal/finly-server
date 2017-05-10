class UserGroup::Configuration::Create < UserGroup::Configuration::Base
  attr_accessor :user_group_configuration, :item_ids, :group_type

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    unless params&.dig(:group_type).present?
      add_message :error, 'Error creating Group Configuration. Invalid Type'
      return
    end
  end

  def init
    self.group_type = params[:group_type]
    self.user_group_configuration = {group_item_configuration_mappings_attributes:[]}
    self.item_ids = []
    params[:user_group_configuration]&.each do |key, value|
      user_group_configuration[:group_item_configuration_mappings_attributes] << {user_group_id: key, user_group_item_id: value}
      self.item_ids << value
    end
  end

  def validate
    unless self.group_type.present? and UserGroupConfigurationType.name_for(self.group_type).present?
      add_message :error, 'Error creating Group Configuration. Invalid Type'
      return
    end
    if GroupItemConfigurationMapping.with_type(group_type).with_user_group_item(item_ids).count == self.item_ids.size
      add_message :error, 'Group Item Configuration already exists'
      return
    end
  end

  def process
    config = user.company.user_group_configurations.build user_group_configuration
    unless config.save
      add_message :error, config.errors.full_messages
    end
  end

end