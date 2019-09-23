class AddEscalationPercentageToRentalInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :rental_invoices, :escalation_percentage, :float
  end
end
