class ChangeNameOfSquareFeel < ActiveRecord::Migration[5.2]
  def change
    rename_column :rental_invoices, :square_feel, :square_feet
  end
end
