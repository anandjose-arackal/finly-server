class AddExternalReferenceIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :company_id, :integer, references: "Company", foreign_key: true, index: true
    add_column :payments, :external_reference_id, :integer
  end
end
