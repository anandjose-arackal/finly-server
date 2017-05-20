class UserTeam::Show < UserTeam::Base

  def success
    params[:user_team] = self.user_team
    UserTeam::Show::SuccessPresenter.new(user, params, messages)
  end

  class UserTeam::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :user_team, :user_groups, :users

    def init
      self.user_team = params[:user_team]
      self.user_groups = self.user.company.user_groups
      self.users = UserGroup::Users.(user, filter_group_items: self.user_team.user_group_items.pluck(:id).uniq)&.selected_users
    end

    def selected_group_items
      map = {
          id: user_team.id,
          name: user_team.name,
      }
      groups = {}
      user_team.user_team_group_item_mappings.each do |team_mapping|
        user_group = team_mapping.user_group
        user_group_item = team_mapping.user_group_item
        group_id_s = team_mapping.user_group_id.to_s
        if groups[group_id_s].blank?
          groups[group_id_s] = {id: group_id_s, name: user_group.name, items: []}
        end
        groups[group_id_s][:items] << {id: user_group_item.id, name: user_group_item.name}
      end
      map[:groups] = groups.values
      map[:groups]
    end

  end

end