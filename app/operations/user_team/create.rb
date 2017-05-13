class UserTeam::Create < UserTeam::Base
  attr_accessor :user_group_configuration, :item_ids

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.user_group_configuration = {group_item_configuration_mappings_attributes:[]}
    self.item_ids = []
    params[:user_group_configuration]&.each do |key, value|
      user_group_configuration[:group_item_configuration_mappings_attributes] << {user_group_id: key, user_group_item_id: value}
      self.item_ids << value
    end
  end

  def process
    config = user.company.user_group_configurations.build user_group_configuration
    unless config.save
      add_message :error, config.errors.full_messages
    end
  end

end