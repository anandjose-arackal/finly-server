class AddInvoiceVendorAndBankAccountFromPayments < ActiveRecord::Migration[4.2]
  def change
    Invoice.all.each do |invoice|
      payment = invoice.payments.first
      if payment.present?
        receiving_account = payment.receiving_account
        receiving_vendor = payment.receiving_user
        invoice.update(receiving_account: receiving_account)
        if receiving_vendor.is_a?(YesBankVendor)
          invoice.update(vendor: receiving_vendor)
        end
      end
    end
  end
end
