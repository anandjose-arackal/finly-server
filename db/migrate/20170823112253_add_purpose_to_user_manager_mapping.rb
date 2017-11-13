class AddPurposeToUserManagerMapping < ActiveRecord::Migration
  def change
    add_column :user_manager_mappings, :purpose_id, :integer, references: "Purpose", foreign_key: true, index: true
  end
end
