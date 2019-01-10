class AddMobileOnlyInviteToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :mobile_only_invite, :boolean, default: false
  end
end
