class CreatePhysicalUnits < ActiveRecord::Migration[4.2]
  def change
    create_table :physical_units do |t|
      t.string :name
      t.string :symbol

      t.timestamps null: false
    end


  end
end
