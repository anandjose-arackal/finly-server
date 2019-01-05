class CreateCustomers < ActiveRecord::Migration[4.2]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :email
      t.string :mobile_number
      t.text :description
      t.references :company

      t.timestamps null: false
    end
  end
end
