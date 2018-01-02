class AddCodeToGstStateCodes < ActiveRecord::Migration
  def change
    add_column :gst_state_codes, :state_code, :string
  end
end
