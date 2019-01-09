class MigrateDelegationEnabledToVacationDelegateEnabledInUsers < ActiveRecord::Migration
  def change
    User.all.find_each do |user|
      user.update_column('vacation_delegate_enabled', user.delegation_enabled)
      user.update_column('delegation_enabled', false)
    end
  end
end
