class UserTeam::Create < UserTeam::Base
  attr_accessor :user_team_configuration

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    unless params&.dig(:name).present?
      add_message :error, 'Name cannot be blank'
    end
  end

  def init
    self.user_team_configuration = {name: params[:name], user_team_group_item_mappings_attributes: []}
    item_ids = []
    params[:user_team_items]&.each do |id|
      next if item_ids.include?(id)
      group = UserGroupItem.find_by(id: id)&.user_group
      next unless group.present? and group.company_id == user.company_id
      user_team_configuration[:user_team_group_item_mappings_attributes] << {user_group_id: group.id, user_group_item_id: id}
      item_ids << id
    end
  end

  def validate
    # Check if all group item and groups exists and that they belong to the given company

  end

  def process
    config = user.company.user_teams.build user_team_configuration
    unless config.save
      add_message :error, config.errors.full_messages
    end
  end

end