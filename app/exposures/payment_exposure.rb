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
      record.reference_resource.bbps_ref_id
    when 'CardTransaction'
      record.reference_resource.reference_id
    when 'IciciBankTransaction', 'KotakBankTransaction', 'YesBankTransaction'
      record.reference_resource.utr
    when 'Payment', 'Report', 'BankTransaction'
      nil
    when 'VirtualAccountTransaction'
      record.reference_resource.transfer_id
    else
      nil
    end
  end

  attribute :initiating_account_type_name do
    account_name(record.initiating_user, record.initiating_account)
  end

  attribute :receiving_account_type_name do
    account_name(record.receiving_user, record.receiving_account)
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
      record.purchase_order_parent.delivery_location
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
      record.purchase_order_parent.vendor_location
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
    if days < 0
      "Overdue by #{days.abs} days"
    else
      "#{days} days"
    end
  end

  attribute :transaction_period_from do
    record.invoice_parent&.transaction_service_period_from
  end

  attribute :transaction_period_to do
    record.invoice_parent&.transaction_service_period_to
  end

  attribute :gross_amount do

  end

  attribute :discount do

  end

  attribute :cgst do

  end

  attribute :sgst do

  end

  attribute :igst do

  end

  attribute :tds_slab do

  end

  attribute :tds_amount do

  end

  attribute :freight do

  end

  attribute :net_payable do

  end

  attribute :advance_paid do

  end

  attribute :balance_payable do

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