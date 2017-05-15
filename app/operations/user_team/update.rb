class UserTeam::Update < UserTeam::Base

  def process
    items_ids = (params[:user_team_items] or [])
    mapping_to_destory = []

    existing_items = self.user_team.user_team_group_item_mappings.pluck(:user_group_item_id).uniq

    # Items to Destroy
    self.user_team.user_team_group_item_mappings.each do |mapping|
      unless items_ids.include?(mapping.id)
        mapping_to_destory << mapping.id
      end
    end
    self.user_team.user_team_group_item_mappings.with_id(mapping_to_destory).each do |mapping|
      mapping.destroy
    end

    items_ids.each do |item_id|
      # Items to Create
      unless existing_items.include?(item_id)
        group = UserGroupItem.find_by(id: item_id)&.user_group
        next unless group.present? and group.company_id == user.company_id
        self.user_team.user_team_group_item_mappings.build user_group_id: group.id, user_group_item_id: item_id
      end
    end
    self.user_team.save
  end

end