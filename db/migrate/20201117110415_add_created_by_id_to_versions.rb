class AddCreatedByIdToVersions < ActiveRecord::Migration[6.0]
  def change
    add_column :versions, :created_by_id, :integer, references: "User", foreign_key: true, index: true
  end
end
