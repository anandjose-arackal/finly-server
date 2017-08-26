class AddPurposeToUserRoleMapping < ActiveRecord::Migration
  def change
    add_column :user_role_mappings, :purpose_id, :integer, references: "MappingPurpose", foreign_key: true, index: true
  end
end
