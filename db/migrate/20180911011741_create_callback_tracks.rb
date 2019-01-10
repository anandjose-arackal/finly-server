class CreateCallbackTracks < ActiveRecord::Migration[4.2]
  def change
    create_table :callback_tracks do |t|
      t.references :company, index: true, foreign_key: true
      t.string :request
      t.string :response
      t.integer :entity_id, polymorphic: true
      t.string :entity_type, polymorphic: true

      t.timestamps null: false
    end
  end
end
