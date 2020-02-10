class AddEscalationPercentageToGeneralInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :general_invoices, :escalation_percentage, :float
  end
end
