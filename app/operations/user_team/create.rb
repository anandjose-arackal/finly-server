class UserTeam::Create < UserTeam::Base
  attr_accessor :user_team_configuration, :item_ids

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
    self.user_team_configuration = {name: params[:name], user_team_group_item_mappings:[]}
    self.item_ids = []
    params[:user_team_configuration]&.each do |key, value|
      user_team_configuration[:user_team_group_item_mappings] << {user_group_id: key, user_group_item_id: value}
      self.item_ids << value
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