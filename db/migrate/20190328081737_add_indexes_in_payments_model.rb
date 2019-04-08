class AddIndexesInPaymentsModel < ActiveRecord::Migration[5.2]
  def change
    add_index :payments, :external_reference_id
    add_index :payments, :company_id
    add_index :payments, :reference_id
  end
end
