class AddAdminNoteToCardAssignRequests < ActiveRecord::Migration
  def change
    add_column :card_assign_requests, :admin_note, :text
  end
end
