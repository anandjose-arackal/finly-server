class AddPurposeToUserManagerMapping < ActiveRecord::Migration[4.2]
  def change
    add_column :user_manager_mappings, :purpose_id, :integer, references: "Purpose", foreign_key: true, index: true
  end
end
