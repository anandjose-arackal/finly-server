class CreateProcurementTracks < ActiveRecord::Migration[4.2]
  def change
    create_table :procurement_tracks do |t|
      t.string :name
      t.text :description

      t.timestamps null: false
    end
  end
end
