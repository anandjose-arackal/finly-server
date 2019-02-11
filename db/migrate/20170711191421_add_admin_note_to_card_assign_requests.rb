class AddAdminNoteToCardAssignRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :card_assign_requests, :admin_note, :text
  end
end
