class SecurityPolicy::Config

  HIGH = {
      browser: {
          client: {otp_verify: true},
          ip: {otp_verify: true},
          user_agent: {otp_verify: true},
          inactivity_timeout: 30.minutes,
          concurrent_logins: 2
      },
      password: {
          minimum_score: 2,
          mandate_special_character: true,
          mandate_numbers: true,
          mandate_lowercase: true,
          mandate_uppercase: true,
          expire_after: 90.days
      },
      account_lock: {
          max_attempts: 10,
          within_timeframe: 30.minutes,
          locking_period: 30.minutes
      }
  }

  MEDIUM = {
      browser: {
          client: {otp_verify: false},
          ip: {otp_verify: false},
          user_agent: {otp_verify: false},
          inactivity_timeout: 1.hours,
          concurrent_logins: 10
      },
      password: {
          minimum_score: 2,
          mandate_special_character: true,
          mandate_numbers: true,
          mandate_lowercase: true,
          mandate_uppercase: true,
          expire_after: 90.days
      },
      account_lock: {
          max_attempts: 10,
          within_timeframe: 30.minutes,
          locking_period: 30.minutes
      }
  }

  LOW = {
      browser: {
          client: {otp_verify: false},
          ip: {otp_verify: false},
          user_agent: {otp_verify: false},
          inactivity_timeout: 8.hours,
          concurrent_logins: 10
      },
      password: {
          minimum_score: 1,
          mandate_special_character: false,
          mandate_numbers: false,
          mandate_lowercase: false,
          mandate_uppercase: false,
          expire_after: nil
      },
      account_lock: {
          max_attempts: 20,
          within_timeframe: 30.minutes,
          locking_period: 30.minutes
      }
  }

  ROLE_LEVELS = {
      admin: HIGH,
      finance_manager: HIGH,
      manager: MEDIUM,
      employee: LOW,
      reviewer: MEDIUM,
      initiator: LOW,
      auditor: HIGH,
      travel_manager: MEDIUM,
      purchaser: HIGH,
      receiver: MEDIUM,
      creditor: HIGH,
      purchase_request_initiator: LOW,
      purchase_request_reviewer: MEDIUM,
      purchase_order_initiator: LOW,
      purchase_order_reviewer: MEDIUM,
      goods_receiver: LOW,
      invoice_initiator: LOW,
      invoice_reviewer: MEDIUM,
      bank_payment_request_initiator: MEDIUM,
      bank_payment_request_reviewer: LOW,
      bank_payment_request_creditor: HIGH,
      item_master_manager: HIGH,
      inventory_manager: MEDIUM,
      vendor_creator: MEDIUM,
      vendor_reviewer: MEDIUM,
      policy_admin: HIGH,
      vendor_manager: HIGH,
      bank_payment_request_auditor: HIGH,
      budget_manager: HIGH,
      non_po_initiator: LOW,
      purchase_request_auditor: HIGH,
      purchase_order_auditor: HIGH,
      invoice_auditor: HIGH,
      vendor_auditor: HIGH,
      payment_agreement_initiator: LOW,
      payment_agreement_reviewer: MEDIUM,
      payment_agreement_auditor: HIGH,
      po_invoice_initiator: LOW,
      po_invoice_reviewer: MEDIUM,
      po_invoice_auditor: HIGH,
      non_po_invoice_initiator: LOW,
      non_po_invoice_reviewer: MEDIUM,
      non_po_invoice_auditor: HIGH
  }.with_indifferent_access

  # ROLE_LEVELS = {
  #     # Low
  #     employee: LOW,
  #     purchaser: LOW,
  #     receiver: LOW,
  #     purchase_request_initiator: LOW,
  #     purchase_order_initiator: LOW,
  #     goods_receiver: LOW,
  #     invoice_initiator: LOW,
  #     bank_payment_request_initiator: LOW,
  #     vendor_creator: LOW,
  #     non_po_initiator: LOW,
  #     po_invoice_initiator: LOW,
  #     po_invoice_reviewer: LOW,
  #     po_invoice_auditor: LOW,
  #     non_po_invoice_initiator: LOW,
  #     non_po_invoice_reviewer: LOW,
  #     non_po_invoice_auditor: LOW,
  #
  #     # Medium
  #     manager: MEDIUM,
  #     travel_manager: MEDIUM,
  #     purchase_request_reviewer: MEDIUM,
  #     purchase_order_reviewer: MEDIUM,
  #     invoice_reviewer: MEDIUM,
  #     bank_payment_request_reviewer: MEDIUM,
  #     item_master_manager: MEDIUM,
  #     inventory_manager: MEDIUM,
  #     vendor_reviewer: MEDIUM,
  #     policy_admin: MEDIUM,
  #     vendor_manager: MEDIUM,
  #     budget_manager: MEDIUM,
  #
  #     # High
  #     admin: HIGH,
  #     finance_manager: HIGH,
  #     auditor: HIGH,
  #     creditor: HIGH,
  #     bank_payment_request_creditor: HIGH,
  #     bank_payment_request_auditor: HIGH,
  #     purchase_request_auditor: HIGH,
  #     purchase_order_auditor: HIGH,
  #     invoice_auditor: HIGH,
  #     vendor_auditor: HIGH,
  # }.with_indifferent_access

  def self.config_for(roles, *keys)
    values = []
    roles.each do |role|
      policy = (ROLE_LEVELS[role] || HIGH)&.dig(*keys) # Default to high unless specified
      values << policy
    end
    values = values.reject {|value| value.blank?}
    values
  end

end