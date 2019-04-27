class AddCreatedByIdAndCompanyToTemporaryFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :temporary_files, :created_by_id, :integer, references: "User", foreign_key: true, index: true
    add_column :temporary_files, :company_id, :integer, references: "Company", foreign_key: true, index: true
  end
end
