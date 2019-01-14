class AddCategoryToPaymentFromInvoice < ActiveRecord::Migration[4.2]
  def change

    yes_bank_vendors = YesBankVendor.all

    for vendor in yes_bank_vendors
      payments = vendor.receiving_payments

      for payment in payments
        if payment.invoice.present?
          if payment.invoice.category_id.present?
            payment.update(category_id: payment.invoice.category_id)
          end
        end
      end
    end


  end
end
