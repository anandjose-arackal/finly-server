class UpdateDefaultTeamMappingPolicy < ActiveRecord::Migration
  def change
    User.all.each do |user|
      user.team_mapping.where(policy_id: nil)&.update_all(policy_id: user.company.default_policy.id)
    end
  end
end
