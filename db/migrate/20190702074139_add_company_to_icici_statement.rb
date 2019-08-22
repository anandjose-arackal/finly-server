class AddCompanyToIciciStatement < ActiveRecord::Migration[5.2]
  def change
    add_column :icici_statements, :company_id, :integer, references: "Company", foreign_key: true, index: true
  end
end
