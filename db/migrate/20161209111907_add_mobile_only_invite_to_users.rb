class AddMobileOnlyInviteToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mobile_only_invite, :boolean, default: false
  end
end
