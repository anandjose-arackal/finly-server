class AddTatToDlrm < ActiveRecord::Migration[5.2]
  def change
    add_column :document_level_reviewer_mappings, :tat, :integer, index: true
    add_column :document_level_reviewer_mappings, :tat_added_by_script, :boolean, index: true, default: false
  end
end
