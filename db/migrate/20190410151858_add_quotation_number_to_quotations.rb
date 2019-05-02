class AddQuotationNumberToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :quotation_number, :string
    add_index :quotations, :quotation_number
  end
end
