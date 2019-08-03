PaymentProcessorRules::Checker.new 'PaymentChecker' do

  section "Documents cannot have payments that total more than it's total" do

    premise :checking_multiple_payments_against_document do

      rule "Invoices cannot have payments that total more than it's total" do
        payment = params[:payment]
        if payment.parent_type == "Invoice"
          invoice = payment.parent
          successful_payments = invoice.payments.successful
          if successful_payments.joins(:amount).sum(:value).to_f > invoice.balance_due&.value.to_f
            message "This payment cannot be processed as the sum total of payments against this invoice exceeds the invoice amount"
            fail
          end
        end
      end

      rule "Purchase Order advances cannot have payments that total more than it's net advance" do
        payment = params[:payment]
        if payment.parent_type == "PurchaseOrder"
          purchase_order = payment.parent
          successful_payments = purchase_order.advance_payments.successful
          if successful_payments.joins(:amount).sum(:value).to_f > purchase_order.advance_amount&.value.to_f
            message "This payment cannot be processed as the sum total of payments against this PO Advance exceeds the invoice amount"
            fail
          end
        end
      end
    end
  end

end