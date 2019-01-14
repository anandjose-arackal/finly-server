class AddCodeToGstStateCodes < ActiveRecord::Migration[4.2]
  def change
    add_column :gst_state_codes, :state_code, :string
  end
end
