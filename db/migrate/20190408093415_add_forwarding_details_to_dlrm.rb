class AddForwardingDetailsToDlrm < ActiveRecord::Migration[5.2]
  def change
    add_column :document_level_reviewer_mappings, :forwarded, :boolean, default: false
    add_column :document_level_reviewer_mappings, :forwarded_by_id, :integer, references: 'User', foreign_key: true, index: true
    add_column :document_level_reviewer_mappings, :forwarded_to_id, :integer, references: 'User', foreign_key: true, index: true
  end
end
