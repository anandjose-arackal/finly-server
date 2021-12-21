class AddReportingAdvanceField < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :reporting_advance_amount, :decimal, precision: 20, scale: 10, default: 0
  end
end
