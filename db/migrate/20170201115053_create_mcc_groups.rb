class CreateMccGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :mcc_groups do |t|
      t.string :name
      t.string :code

      t.timestamps null: false
    end
  end
end
