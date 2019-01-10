class AddAdminNoteToIndividualKyc < ActiveRecord::Migration[4.2]
  def change
    add_column :individual_kycs, :admin_note, :text
  end
end
