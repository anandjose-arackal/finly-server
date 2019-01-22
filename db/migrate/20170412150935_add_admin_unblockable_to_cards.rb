class AddAdminUnblockableToCards < ActiveRecord::Migration[4.2]
  def change
    add_column :cards, :admin_unblockable, :boolean, default: true
  end
end
