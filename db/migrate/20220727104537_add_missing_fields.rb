class AddMissingFields < ActiveRecord::Migration[6.0]
  def change
    add_column :credit_note_items, :revised_tax_percentage, :decimal, precision: 20, scale: 10

  end
end
