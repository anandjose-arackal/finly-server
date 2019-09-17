class CreateBillingTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :billing_types do |t|
      t.string :name
      t.integer :company_id

      t.timestamps
    end
  end
end
