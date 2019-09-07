class DestroyGstConfigsTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :gst_configs
  end
end
