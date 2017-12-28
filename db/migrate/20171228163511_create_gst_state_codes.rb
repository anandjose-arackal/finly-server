class CreateGstStateCodes < ActiveRecord::Migration
  def change
    create_table :gst_state_codes do |t|
      t.string :name

      t.timestamps null: false
    end


  end
end
