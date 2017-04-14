class AddAdminUnblockableToCards < ActiveRecord::Migration
  def change
    add_column :cards, :admin_unblockable, :boolean, default: true
  end
end
