class CreateProcurementStatuses < ActiveRecord::Migration
  def change
    create_table :procurement_statuses do |t|
      t.string :name
      t.text :description

      t.timestamps null: false
    end
  end
end
