class SecurityPolicy::Config

  FEATURE_TOGGLE_PREFIX = 'permissions/security/policy'.freeze
  DURATIONS = %w[year years month months week weeks day days hour hours minute minutes second seconds].freeze

  POLICY = {
    high: {
      browser: {
        client: { otp_verify: true },
        ip: {
          otp_verify: true,
          restrict: nil
        },
        user_agent: { otp_verify: true },
        inactivity_timeout: 1.hours,
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
    },
    medium: {
      browser: {
        client: { otp_verify: false },
        ip: {
          otp_verify: false,
          restrict: nil
        },
        user_agent: { otp_verify: false },
        inactivity_timeout: 2.hours,
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
    },
    low: {
      browser: {
        client: { otp_verify: false },
        ip: {
          otp_verify: false,
          restrict: nil
        },
        user_agent: { otp_verify: false },
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
  }.freeze

  # HIGH = {
  #   browser: {
  #     client: { otp_verify: true },
  #     ip: { otp_verify: true },
  #     user_agent: { otp_verify: true },
  #     inactivity_timeout: 1.hours,
  #     concurrent_logins: 2
  #   },
  #   password: {
  #     minimum_score: 2,
  #     mandate_special_character: true,
  #     mandate_numbers: true,
  #     mandate_lowercase: true,
  #     mandate_uppercase: true,
  #     expire_after: 90.days
  #   },
  #   account_lock: {
  #     max_attempts: 10,
  #     within_timeframe: 30.minutes,
  #     locking_period: 30.minutes
  #   }
  # }.freeze
  #
  # MEDIUM = {
  #   browser: {
  #     client: { otp_verify: false },
  #     ip: { otp_verify: false },
  #     user_agent: { otp_verify: false },
  #     inactivity_timeout: 2.hours,
  #     concurrent_logins: 10
  #   },
  #   password: {
  #     minimum_score: 2,
  #     mandate_special_character: true,
  #     mandate_numbers: true,
  #     mandate_lowercase: true,
  #     mandate_uppercase: true,
  #     expire_after: 90.days
  #   },
  #   account_lock: {
  #     max_attempts: 10,
  #     within_timeframe: 30.minutes,
  #     locking_period: 30.minutes
  #   }
  # }.freeze
  #
  # LOW = {
  #   browser: {
  #     client: { otp_verify: false },
  #     ip: { otp_verify: false },
  #     user_agent: { otp_verify: false },
  #     inactivity_timeout: 8.hours,
  #     concurrent_logins: 10
  #   },
  #   password: {
  #     minimum_score: 1,
  #     mandate_special_character: false,
  #     mandate_numbers: false,
  #     mandate_lowercase: false,
  #     mandate_uppercase: false,
  #     expire_after: nil
  #   },
  #   account_lock: {
  #     max_attempts: 20,
  #     within_timeframe: 30.minutes,
  #     locking_period: 30.minutes
  #   }
  # }.freeze

  ROLE_LEVELS = {
    admin: :high,
    finance_manager: :high,
    manager: :medium,
    employee: :low,
    reviewer: :medium,
    initiator: :low,
    auditor: :high,
    travel_manager: :medium,
    purchaser: :high,
    receiver: :medium,
    creditor: :high,
    purchase_request_initiator: :low,
    purchase_request_reviewer: :medium,
    purchase_order_initiator: :low,
    purchase_order_reviewer: :medium,
    goods_receiver: :low,
    invoice_initiator: :low,
    invoice_reviewer: :medium,
    bank_payment_request_initiator: :medium,
    bank_payment_request_reviewer: :low,
    bank_payment_request_creditor: :high,
    item_master_manager: :high,
    inventory_manager: :medium,
    vendor_creator: :medium,
    vendor_reviewer: :medium,
    vendor_bulk_importer: :medium,
    policy_admin: :high,
    vendor_manager: :high,
    bank_payment_request_auditor: :high,
    budget_manager: :high,
    non_po_initiator: :low,
    purchase_request_auditor: :high,
    purchase_order_auditor: :high,
    invoice_auditor: :high,
    vendor_auditor: :high,
    payment_agreement_initiator: :low,
    payment_agreement_reviewer: :medium,
    payment_agreement_auditor: :high,
    po_invoice_initiator: :low,
    po_invoice_reviewer: :medium,
    po_invoice_auditor: :high,
    non_po_invoice_initiator: :low,
    non_po_invoice_reviewer: :medium,
    non_po_invoice_auditor: :high,
    utility_bill_master_initiator: :low,
    utility_bill_master_reviewer: :medium,
    utility_bill_initiator: :low,
    utility_bill_reviewer: :medium,
    credit_note_initiator: :low,
    credit_note_reviewer: :medium,
    credit_note_auditor: :high,
    agreement_invoice_initiator: :low,
    agreement_invoice_reviewer: :medium,
    agreement_invoice_auditor: :high
  }.with_indifferent_access.freeze

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

  def self.config_for(user, roles, *keys)
    values = []
    policy = build_policy(user)

    roles.each do |role|
      values << (policy[ROLE_LEVELS[role]] || policy[:high])&.dig(*keys) # Default to high unless specified
    end
    values = values.reject { |value| value.blank? }
    values
  end

  def self.build_policy(user)
    policy = POLICY.deep_dup
    flags = user.feature_toggle.flags
    parse_hash(policy, flags, FEATURE_TOGGLE_PREFIX)
  end

  def self.parse_hash(policy, flags, path = '')
    policy.each do |key, value|
      if value.is_a?(Hash)
        policy[key] = parse_hash(value, flags, "#{path}/#{key}")
      else
        full_path = "#{path}##{key}"
        if !flags&.has_key?(full_path)
          policy[key] = value
        elsif [true, false].include?(value)
          # Boolean, should fetch the flag
          policy[key] = flags.dig(full_path, :enabled)
        else
          policy[key] = parse_value(flags[full_path][:value], value)
        end
      end
    end
    policy
  end

  def self.parse_value(value, default_value)
    return default_value if value.blank?

    # Using JSON.parse as it would help us build integers, strings, numbers from string
    begin
      new_value = JSON.parse("{\"value\": #{value}}")&.dig('value')
    rescue StandardError => e
      # Todo raise with sentry
      return default_value
    end

    # This is to allow support for defining values in hours
    if new_value.is_a?(String)
      DURATIONS.each do |duration|
        if new_value.ends_with?(duration)
          splits = new_value.split('.')
          new_value = splits[0].to_i.send(splits[1])
          break
        end
      end
    end

    new_value || value
  end

  def self.generate_flags
    hash = flatten_hash(POLICY)
    result = {}
    hash.each do |k, v|
      result["#{FEATURE_TOGGLE_PREFIX}/#{k}"] = v
    end
    result
  end

  def self.flatten_hash(hash)
    hash.each_with_object({}) do |(k, v), h|
      if v.is_a? Hash
        flatten_hash(v).map do |h_k, h_v|
          if h_v.is_a?(Hash) or h_k.to_s.include?('#')
            h["#{k}/#{h_k}"] = h_v
          else
            h["#{k}##{h_k}"] = h_v
          end
        end
      else
        h[k] = v
      end
    end
  end

end