class AddTenancyPeriodToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :tenancy_period, :integer
  end
end
