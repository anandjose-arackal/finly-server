class AddMoreFieldsToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :gst, :string
  end
end
