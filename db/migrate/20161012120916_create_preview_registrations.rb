class CreatePreviewRegistrations < ActiveRecord::Migration
  def change
    create_table :preview_registrations do |t|
      t.string :email
      t.text :company
      t.string :phone_number
      t.text :name

      t.timestamps null: false
    end
  end
end
