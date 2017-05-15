class UserTeam::Index < UserTeam::Base
  attr_accessor :user_teams

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
    self.user_teams = user.company.user_teams
  end

  def validate

  end

  def success
    params[:user_teams] = self.user_teams
    UserTeam::Index::SuccessPresenter.new(user, params, messages)
  end

  class UserTeam::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :user_teams, :user_groups

    def init
      self.user_teams = params[:user_teams]
    end

    def teams_mapping
      teams = []
      self.user_teams.each do |team|
        map = {
            id: team.id,
            name: team.name,
        }
        groups = {}
        team.user_team_group_item_mappings.each do |team_mapping|
          user_group = team_mapping.user_group
          user_group_item = team_mapping.user_group_item
          group_id_s = team_mapping.user_group_id.to_s
          if groups[group_id_s].blank?
            groups[group_id_s] = {id: group_id_s, name: user_group.name, items: []}
          end
          groups[group_id_s][:items] << {id: user_group_item.id, name: user_group_item.name}
        end
        map[:groups] = groups.values
        teams << map
      end
      teams
    end

  end


end