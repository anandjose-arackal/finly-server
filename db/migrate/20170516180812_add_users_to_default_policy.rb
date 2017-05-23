class AddUsersToDefaultPolicy < ActiveRecord::Migration
  def change
    User.all.each do |user|
      user.policy_user_mappings.build(policy_id: user.company.default_policy.id).save
    end
  end
end
