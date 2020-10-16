class PaymentExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :date, record_attribute: true
  attribute :narration, record_attribute: true
  attribute :reference_id, record_attribute: true
  attribute :gl_name, record_attribute: true
  attribute :amount, record_attribute: true, exposure: true
  attribute :initiating_user, record_attribute: true, exposure: true
  attribute :initiating_account, record_attribute: true, exposure: true
  attribute :receiving_user, record_attribute: true, exposure: true
  attribute :receiving_account, record_attribute: true, exposure: true
  attribute :receiving_account_bank_account, exposure: true, record_attribute: true
  attribute :receiving_account_card, exposure: true, record_attribute: true
  attribute :receiving_account_yes_bank_company_account, exposure: true, record_attribute: true
  attribute :receiving_account_utility_bills_account, exposure: true, record_attribute: true
  attribute :receiving_account_user_pocket, exposure: true, record_attribute: true
  attribute :receiving_account_user_wallet, exposure: true, record_attribute: true
  attribute :receiving_account_vendor_payment_wallet, exposure: true, record_attribute: true
  attribute :receiving_account_bbps_biller, exposure: true, record_attribute: true
  attribute :receiving_account_cash_on_hand, exposure: true, record_attribute: true
  attribute :status, record_attribute: true, exposure: true
  attribute :payment_order_id, record_attribute: true, exposure: true
  attribute :payment_order, record_attribute: true, exposure: true
  attribute :payment_mode, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :updated_at, record_attribute: true
  attribute :processed_at, record_attribute: true
  attribute :last_retried_at, record_attribute: true
  attribute :note, record_attribute: true
  attribute :initiating_account_number do
    account_name(record, :initiating_account)
  end
  attribute :initiating_account_code do
    account_code(record, :initiating_account)
  end
  attribute :receiving_account_number do
    account_name(record, :receiving_account)
  end
  attribute :receiving_account_code do
    account_code(record, :receiving_account)
  end
  attribute :utr do
    case record.reference_resource_type
    when 'BbpsYesBankTransaction'
      record.reference_resource&.bbps_ref_id
    when 'CardTransaction'
      record.reference_resource&.reference_id
    when  'YesBankTransaction'
      (record.utr.present? ? record&.utr : record.reference_resource&.bank_reference_number)
    when 'IciciBankTransaction', 'KotakBankTransaction'
      (record.utr.present? ? record&.utr : record.reference_resource&.utr)
    when 'Payment', 'Report', 'BankTransaction'
      nil
    when 'VirtualAccountTransaction'
      record.reference_resource&.transfer_id
    else
      nil
    end
  end

  attribute :parent_type_name do
    case record.parent_type
    when 'Invoice', 'PurchaseOrder', 'BeneficiaryPayment', 'SecurityDeposit'
      record.parent_type.titleize
    when 'BbpsBill'
      'Utility Bill'
    when nil
      nil
    else
      record.parent_type&.titleize
    end
  end

  attribute :vendor, exposure: true do
    next unless record.receiving_user_type == 'YesBankVendor'

    record.receiving_user
  end

  attribute :cost_center, exposure: true do
    case record.parent_type
    when 'Invoice', 'PurchaseOrder'
      if record.parent.cost_allocation_items
        "Multiple"
      else
        record.parent.cost_center
      end
    when 'BeneficiaryPayment', 'BbpsBill', 'SecurityDeposit'
      record.cost_center
    else
      nil
    end
  end

  attribute :department, exposure: true do
    case record.parent_type
    when 'Invoice', 'PurchaseOrder'
      if record.parent.cost_allocation_items
        "Multiple"
      else
        record.parent.department
      end
    when 'BeneficiaryPayment', 'BbpsBill', 'SecurityDeposit'
      record.department
    else
      nil
    end
  end

  attribute :billing_location, exposure: true do
    record.parent.location
  end

  attribute :shipping_location, exposure: true do
    case record.parent_type
    when 'Invoice'
      record.invoice_parent.delivery_location
    when 'PurchaseOrder'
      record.purchase_order_parent&.delivery_location
    when 'BbpsBill', 'BeneficiaryPayment', 'SecurityDeposit'
      nil
    else
      nil
    end
  end

  attribute :vendor_location, exposure: true do
    case record.parent_type
    when 'Invoice'
      record.invoice_parent.vendor_location
    when 'PurchaseOrder'
      record.purchase_order_parent&.vendor_location
    when 'BeneficiaryPayment'
      record.beneficiary_payment_parent.vendor_location
    when 'SecurityDeposit'
      record.security_deposit_parent.vendor_location
    when 'BbpsBill'
      nil
    else
      nil
    end
  end

  attribute :category, exposure: true do
    record.beneficiary_payment_parent&.category
    # Todo bbps biller
  end

  attribute :invoice_date do
    case record.parent_type
    when 'Invoice'
      record.parent.date
    when 'BeneficiaryPayment'
      record.parent.invoice_date
    when 'BbpsBill'
      record.parent.bill_date
    when 'PurchaseOrder', 'SecurityDeposit'
      nil
    else
      nil
    end
  end

  attribute :due_date do
    case record.parent_type
    when 'Invoice', 'BbpsBill'
      record.parent.due_date
    when 'BeneficiaryPayment'
      record.parent.invoice_due_date
    when 'PurchaseOrder', 'SecurityDeposit'
      nil
    else
      nil
    end
  end

  attribute :due_in_days do
    next if record.payment_status_id == PaymentStatus.id_for(:completed)
    next if due_date.blank?

    days = (due_date - Date.today).to_i
    next if PaymentStatus.id_for(:completed) == record.payment_status_id

    if days < 0
      "Overdue by #{days.abs.to_i} days"
    else
      "#{days.to_i} days"
    end
  end

  attribute :transaction_period_from do
    record.invoice_parent&.transaction_service_period_from
  end

  attribute :transaction_period_to do
    record.invoice_parent&.transaction_service_period_to
  end

  attribute :gross_amount, exposure: true do
    case record.parent_type
    when 'Invoice'
      record.invoice_parent&.gross_amount
    when 'BbpsBill'
      record.bbps_bill_parent&.amount
    when 'BeneficiaryPayment'
      record.beneficiary_payment_parent&.gross_amount
    when 'PurchaseOrder'
      record.purchase_order_parent&.requested_advance_amount
    when 'SecurityDeposit'
      record.security_deposit_parent&.original_amount
    else
      nil
    end
  end

  attribute :discount, exposure: true do
    case record.parent_type
    when 'Invoice'
      record.invoice_parent.discount_amount
    when 'BbpsBill', 'BeneficiaryPayment', 'PurchaseOrder','SecurityDeposit'
      nil
    else
      nil
    end
  end

  attribute :cgst_amount do
    case record.parent_type
    when 'Invoice'
      record.invoice_parent.to_exposure.cgst_amount
    when 'BbpsBill'
      nil
    when 'BeneficiaryPayment'
      record.beneficiary_payment_parent.to_exposure.cgst_amount
    when 'PurchaseOrder'
      nil
    when 'SecurityDeposit'
      nil
    else
      nil
    end
  end

  attribute :sgst_amount do
    cgst_amount
  end

  attribute :igst_amount do
    case record.parent_type
    when 'Invoice'
      record.invoice_parent.to_exposure.igst_amount
    when 'BbpsBill'
      nil
    when 'BeneficiaryPayment'
      record.beneficiary_payment_parent.to_exposure.igst_amount
    when 'PurchaseOrder'
      nil
    when 'SecurityDeposit'
      nil
    else
      nil
    end
  end

  attribute :tds_slab, exposure: true do
    case record.parent_type
    when 'Invoice'
      record.invoice_parent.tds_slab
    when 'BbpsBill'
      nil
    when 'BeneficiaryPayment'
      record.beneficiary_payment_parent.tds_slab
    when 'PurchaseOrder'
      record.purchase_order_parent&.advance_tds_slab
    when 'SecurityDeposit'
      nil
    else
      nil
    end
  end

  attribute :tds_amount, exposure: true do
    case record.parent_type
    when 'Invoice'
      record.invoice_parent&.tds_amount
    when 'BbpsBill'
      nil
    when 'BeneficiaryPayment'
      record.beneficiary_payment_parent&.tds_amount
    when 'PurchaseOrder'
      record.purchase_order_parent&.advance_tds_amount
    when 'SecurityDeposit'
      nil
    else
      nil
    end
  end


  attribute :freight, exposure: true do
    case record.parent_type
    when 'Invoice'
      record.invoice_parent.freight_amount
    else
      nil
    end
  end

  attribute :early_payment_discount do
    case record.parent_type
    when 'BbpsBill'
      # Todo after the respective attributes have been created in BBPS bill
      nil
    else
      nil
    end
  end

  attribute :late_payment_fee do
    case record.parent_type
    when 'BbpsBill'
      # Todo after the respective attributes have been created in BBPS bill
      nil
    else
      nil
    end
  end

  attribute :net_amount, exposure: true do
    case record.parent_type
    when 'Invoice'
      record.invoice_parent.net_amount
    when 'BbpsBill'
      record.bbps_bill_parent.total_amount
    when 'BeneficiaryPayment'
      record.beneficiary_payment_parent.net_amount
    when 'PurchaseOrder'
      record.purchase_order_parent&.advance_amount
    when 'SecurityDeposit'
      record.security_deposit_parent.original_amount
    else
      nil
    end
  end

  attribute :advance_paid, exposure: true do
    case record.parent_type
    when 'Invoice'
      record.invoice_parent.advance_amount
    when 'BbpsBill'
      nil
    when 'BeneficiaryPayment'
      record.beneficiary_payment_parent.advance_amount
    when 'PurchaseOrder'
      nil
    when 'SecurityDeposit'
      nil
    else
      nil
    end
  end

  attribute :balance_payable, exposure: true do
    case record.parent_type
    when 'Invoice'
      record.invoice_parent.balance_due
    when 'BbpsBill'
      record.bbps_bill_parent.total_amount
    when 'BeneficiaryPayment'
      record.beneficiary_payment_parent.payable_amount
    when 'PurchaseOrder'
      record.purchase_order_parent&.advance_amount
    when 'SecurityDeposit'
      record.security_deposit_parent.payable_amount
    else
      nil
    end
  end


  private

  def account_name(record, type)
    case record.send("#{type}_type")
    when 'BankAccount'
      record.send("#{type}_bank_account").account_number
    when 'Card'
      record.send("#{type}_card").serial_id
    when 'YesBankCompanyAccount'
      "Company Credits (YesBank)"
    when 'KotakBankCompanyAccount'
      "Company Credits (Kotak)"
    when 'ItzCashCompanyAccount'
      "Company Credits (Card Transfer)"
    when 'IciciBankCompanyAccount'
      "Company Credits (ICICI)"
    when 'UtilityBillsAccount'
      "Company Credits (Utility Bills)"
    when 'UserPocket'
      record.send("#{type}_user_pocket").name
    when 'UserWallet'
      'Finly Money (Card Transfer)'
    when 'VendorPaymentWallet'
      'Finly Money (Bank Transfer)'
    when 'BbpsBiller'
      record.send("#{type}_bbps_biller").biller_name
    when 'CashOnHand'
      "Cash on Hand"
    when 'VirtualBankAccount'
      record.send("#{type}_virtual_account").account_number
    else
      nil
    end
  end

  def account_code(record, type)
    case record.send("#{type}_type")
    when 'BankAccount'
      record.send("#{type}_bank_account").ifsc
    when 'Card'
      record.send("#{type}_card.user").name
    when 'YesBankCompanyAccount'
    when 'KotakBankCompanyAccount'
    when 'IciciBankCompanyAccount'
    when 'ItzCashCompanyAccount'
    when 'UtilityBillsAccount'
    when 'UserPocket'
      record.send("#{type}_user_pocket").user.name
    when 'UserWallet'
      record.send("#{type}_user_wallet").user.name
    when 'VendorPaymentWallet'
      record.send("#{type}_vendor_payment_wallet").user.name
    when 'BbpsBiller'
      'Utility Bill'
    when 'CashOnHand'
      record.send("#{type}_cash_on_hand").user.name
    when 'VirtualBankAccount'
      record.send("#{type}_virtual_account").ifsc
    else
      nil
    end
  end

end