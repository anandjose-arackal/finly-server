class SecurityPolicy::Config

  HIGH = {
      browser: {
          client: {
              otp_verify: true,
          },
          ip: {
              otp_verify: true,
          },
          inactivity_timeout: 30.minutes,
      },
      password: {
          min_score: 3,
          mandate_special_character: true,
          mandate_numbers: true,
          mandate_lowercase: true,
          mandate_uppercase: true,
          min_length: 8,
          expire_after: 90.days,
      },
  }

  MEDIUM = {
      browser: {
          client: {
              otp_verify: false,
              tolerance: :match,
          },
          ip: {
              otp_verify: false,
              tolerance: :country, # verified, :city, :state, :country, :match, :all
          },
          inactivity_timeout: 3.hours,
      },
      password: {
          min_score: 2,
          mandate_special_character: true,
          mandate_numbers: true,
          mandate_lowercase: true,
          mandate_uppercase: true,
          min_length: 8,
          expire_after: 90.days,
      },
  }

  LOW = {
      browser: {
          client: {
              otp_verify: false,
              tolerance: :match,
          },
          ip: {
              otp_verify: true,
              tolerance: :country, # verified, :city, :state, :country, :match, :all
          },
          inactivity_timeout: 6.hours,
      },
      password: {
          min_score: 1,
          mandate_special_character: false,
          mandate_numbers: false,
          mandate_lowercase: false,
          mandate_uppercase: false,
          min_length: 8,
          expire_after: 90.days,
      },
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