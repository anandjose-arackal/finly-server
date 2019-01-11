class AddMoreFieldsToCustomer < ActiveRecord::Migration[4.2]
  def change
    add_column :customers, :gst, :string
  end
end
