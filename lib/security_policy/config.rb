class SecurityPolicy::Config

  HIGH = {
      browser: {
          client: {otp_verify: true},
          ip: {otp_verify: false},
          inactivity_timeout: 1.minute,
          concurrent_logins: 5
      },
      password: {
          minimum_score: 3,
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
          inactivity_timeout: 1.minute,
          concurrent_logins: 10
      },
      password: {
          minimum_score: 2,
          mandate_special_character: true,
          mandate_numbers: true,
          mandate_lowercase: true,
          mandate_uppercase: true,
          expire_after: 180.days
      },
      account_lock: {
          max_attempts: 20,
          within_timeframe: 30.minutes,
          locking_period: 30.minutes
      }
  }

  LOW = {
      browser: {
          client: {otp_verify: false},
          ip: {otp_verify: false},
          inactivity_timeout: 1.minute,
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
      # High
      admin: HIGH,
      finance_manager: HIGH,
      auditor: HIGH,
      creditor: HIGH,
      bank_payment_request_creditor: HIGH,
      bank_payment_request_auditor: HIGH,
      purchase_request_auditor: HIGH,
      purchase_order_auditor: HIGH,
      invoice_auditor: HIGH,
      vendor_auditor: HIGH,

      # Medium
      manager: MEDIUM,
      travel_manager: MEDIUM,
      purchase_request_reviewer: MEDIUM,
      purchase_order_reviewer: MEDIUM,
      invoice_reviewer: MEDIUM,
      bank_payment_request_reviewer: MEDIUM,
      item_master_manager: MEDIUM,
      inventory_manager: MEDIUM,
      vendor_reviewer: MEDIUM,
      policy_admin: MEDIUM,
      vendor_manager: MEDIUM,
      budget_manager: MEDIUM,

      # Low
      employee: LOW,
      purchaser: LOW,
      receiver: LOW,
      purchase_request_initiator: LOW,
      purchase_order_initiator: LOW,
      goods_receiver: LOW,
      invoice_initiator: LOW,
      bank_payment_request_initiator: LOW,
      vendor_creator: LOW,
      non_po_initiator: LOW,
  }.with_indifferent_access

  def self.config_for(roles, *keys)
    values = []
    roles.each do |role|
      values << ROLE_LEVELS[role]&.dig(*keys)
    end
    values
  end

end