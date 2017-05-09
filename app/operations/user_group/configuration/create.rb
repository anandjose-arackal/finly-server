class UserGroup::Configuration::Create < UserGroup::Configuration::Base
  attr_accessor :user_group_configuration

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
  end

  def init
    self.user_group_configuration = {group_item_configuration_mappings_attributes:[]}
    params[:user_group_configuration]&.each do |key, value|
      user_group_configuration[:group_item_configuration_mappings_attributes] << {user_group_id: key, user_group_item_id: value}
    end
  end

  def validate

  end

  def process
    if user.company.user_group_configurations.create user_group_configuration

    end
  end

end