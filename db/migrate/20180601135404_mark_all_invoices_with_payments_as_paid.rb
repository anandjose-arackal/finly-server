class MarkAllInvoicesWithPaymentsAsPaid < ActiveRecord::Migration[4.2]
  def change
    Invoice.all.each do |invoice|
      invoice_amount = invoice.balance_due&.value.to_f
      payments_amount = invoice.payments.successful.joins(:amount).sum(:value)
      if payments_amount >= invoice_amount
        invoice.update(invoice_status_id: InwardInvoiceStatus.id_for(:paid))
      end
    end
  end
end
