class SetInvoiceStatusForAllInvoices < ActiveRecord::Migration
  def change
    Invoice.all.each do |invoice|
      payment = invoice.payments.first

    end
  end
end
