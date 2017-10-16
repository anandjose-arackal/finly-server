class AddReferenceTypeToQuickbooksReference < ActiveRecord::Migration
  def change
    add_column :quickbooks_references, :reference_type_id, :integer, references: "QuickbooksReferenceType", foreign_key: true, index: true
    QuickbooksReferenceType.seed_data
  end
end
