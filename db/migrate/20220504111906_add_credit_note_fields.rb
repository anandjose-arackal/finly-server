class AddCreditNoteFields < ActiveRecord::Migration[6.0]
  def change
    add_column :credit_notes, :vendor_trade_name, :string
    add_column :credit_notes, :vendor_sequence_id, :string
    add_column :credit_notes, :vendor_pan, :string
    add_column :credit_notes, :billing_address_gstin, :string
    add_column :credit_notes, :billing_address_name, :string
    add_column :credit_notes, :shipping_address_gstin, :string
    add_column :credit_notes, :shipping_address_name, :string
  end
end
