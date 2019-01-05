class CreateTravelRequestComments < ActiveRecord::Migration[4.2]
  def change
    create_table :travel_request_comments do |t|
      t.references :travel_request, index: true, foreign_key: true
      t.text :content
      t.references :user, index: true, foreign_key: true
      t.text :note
      t.text :previous_value
      t.text :new_value
      t.text :edited_field

      t.timestamps null: false
    end
  end
end
