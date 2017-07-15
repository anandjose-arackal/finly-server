class AddAdminNoteToIndividualKyc < ActiveRecord::Migration
  def change
    add_column :individual_kycs, :admin_note, :text
  end
end
