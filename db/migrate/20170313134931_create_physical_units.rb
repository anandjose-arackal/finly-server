class CreatePhysicalUnits < ActiveRecord::Migration
  def change
    create_table :physical_units do |t|
      t.string :name
      t.string :symbol

      t.timestamps null: false
    end


  end
end
