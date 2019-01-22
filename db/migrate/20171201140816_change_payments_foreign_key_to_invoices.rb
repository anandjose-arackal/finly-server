class ChangePaymentsForeignKeyToInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :invoice_id, :integer, references: "Invoice", foreign_key: true, index: true
    Payment.all.each do |payment|
      if payment.invoice.present?
        payment.update(invoice_id: payment.invoice&.id)
      end
    end

    # seeding purpose table to include purpose for categories
    Purpose.seed_data
    FieldParentType.create(name: "invoice_line_item")
  end
end