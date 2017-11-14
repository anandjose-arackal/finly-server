class RenameMappingPurposeToPurpose < ActiveRecord::Migration
  def change
    rename_table :mapping_purposes, :purposes
  end
end
