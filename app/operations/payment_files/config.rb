class PaymentFiles::Config

  def self.available_keys
    keys = [nil, 'custom']
    self.available_adapters.each do |adapter|
      keys << adapter[:key]&.to_s
    end
    keys
  end

  def self.available_adapters
    [
        {name: 'Yes Bank', key: :yes_bank, operation: PaymentFiles::Formats::YesBank::Process, validator: PaymentFiles::Formats::YesBank::ValidateConfig}
    ]
  end

  def self.adapter_for(key)
    self.available_adapters.each do |adapter|
      return adapter[:operation] if adapter[:key]&.to_s == key&.to_s
    end
    nil
  end

  def self.validator_for(key)
    self.available_adapters.each do |adapter|
      return adapter[:validator] if adapter[:key]&.to_s == key&.to_s
    end
    nil
  end

end