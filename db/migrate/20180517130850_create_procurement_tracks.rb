class CreateProcurementTracks < ActiveRecord::Migration
  def change
    create_table :procurement_tracks do |t|
      t.string :name
      t.text :description

      t.timestamps null: false
    end
  end
end
