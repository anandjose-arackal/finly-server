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
  attribute :status, record_attribute: true, exposure: true
  attribute :payment_order_id, record_attribute: true, exposure: true
  attribute :payment_order, record_attribute: true, exposure: true
  attribute :payment_mode, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :note, record_attribute: true
  attribute :utr do
    record.reference_resource&.utr
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
  attribute :vendor_account, exposure: true do
    next unless record.receiving_user_type == 'YesBankVendor'

    record.receiving_account
  end
  attribute :cost_center, exposure: true do
    case record.parent_type
    when 'Invoice', 'PurchaseOrder'
      if record.parent.cost_allocation_items
        "Multiple"
      else
        record.parent.cost_center
      end
    when 'BeneficiaryPayment', 'BbpsBill'
      record.cost_center
    when 'SecurityDeposit'
      nil
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
    when 'BeneficiaryPayment', 'BbpsBill'
      record.department
    when 'SecurityDeposit'
      nil
    else
      nil
    end
  end

  attribute :billing_location, exposure: true do
    record.parent.location
  end

  attribute :shipping_location, exposure: true do
    case record.parent_type
    when 'Invoice', 'PurchaseOrder'
        record.parent.delivery_location
    when 'BbpsBill', 'BeneficiaryPayment', 'SecurityDeposit'
      nil
    else
      nil
    end
  end

  attribute :vendor_location, exposure: true do
    case record.parent_type
    when 'Invoice', 'PurchaseOrder', 'BeneficiaryPayment', 'SecurityDeposit'
      record.parent.vendor_location
    when 'BbpsBill'
      nil
    else
      nil
    end
  end

  attribute :category, exposure: true do
    if record.parent_type == 'BeneficiaryPayment'
      record.parent.category
    else
      nil
    end
  end

  private

  def account_name(user, account)
    name = "#{user&.name.to_s}'s "

    case account.class.name
    when "Company", "ItzCashCompanyAccount"
      name = "Company Credits (Card Transfer Pocket)"
    when "CashOnHand"
      name += "Cash on Hand"
    when "Card"
      card_type = Card.unscoped.find_by(id: account.id)&.card_program&.name&.humanize
      name += "#{card_type} Card"
    when "UserWallet"
      name += "Finly Money"
    when "YesBankCompanyAccount"
      name = "Company Credits (Bank Transfer Pocket)"
    when "VendorPaymentWallet"
      name += "Finly Money (Bank Transfer Pocket)"
    when "BankAccount"
      name += "Bank Account (Number: #{account.account_number})"
    when "UserPocket"
      name += "#{account.name}"
    else
      name = ""
    end
    name
  end

end