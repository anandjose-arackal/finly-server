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
        {name: 'HDFC Bank', key: :hdfc_bank, operation: PaymentFiles::Formats::HdfcBank::Process, validator: PaymentFiles::Formats::HdfcBank::ValidateConfig},
        {name: 'Yes Bank', key: :yes_bank, operation: PaymentFiles::Formats::YesBank::Process, validator: PaymentFiles::Formats::YesBank::ValidateConfig},
        {name: 'ICICI Bank', key: :icici_bank, operation: PaymentFiles::Formats::IciciBank::Process, validator: PaymentFiles::Formats::IciciBank::ValidateConfig},
        {name: 'Karnataka Bank', key: :karnataka_bank, operation: PaymentFiles::Formats::KarnatakaBank::Process, validator: PaymentFiles::Formats::KarnatakaBank::ValidateConfig},
        {name: 'Kotak Mahindra Bank', key: :kotak_mahindra_bank, operation: PaymentFiles::Formats::KotakMahindraBank::Process, validator: PaymentFiles::Formats::KotakMahindraBank::ValidateConfig},
        {name: 'Citi', key: :citi, operation: PaymentFiles::Formats::Citi::Process, validator: PaymentFiles::Formats::Citi::ValidateConfig},
        {name: 'Toppr', key: :toppr, operation: PaymentFiles::Formats::Toppr::Process, validator: PaymentFiles::Formats::Toppr::ValidateConfig},
        {name: 'Denave', key: :denave, operation: PaymentFiles::Formats::Denave::Process, validator: PaymentFiles::Formats::Denave::ValidateConfig},
        {name: 'Axis Bank', key: :axis_bank, operation: PaymentFiles::Formats::AxisBank::Process, validator: PaymentFiles::Formats::AxisBank::ValidateConfig},
        {name: 'IDFC Bank', key: :idfc_bank, operation: PaymentFiles::Formats::IdfcBank::Process, validator: PaymentFiles::Formats::IdfcBank::ValidateConfig},
        {name: 'Citi Bank', key: :citi_bank, operation: PaymentFiles::Formats::CitiBank::Process, validator: PaymentFiles::Formats::CitiBank::ValidateConfig},
        {name: 'Stanza Payment', key: :stanza, operation: PaymentFiles::Formats::Stanza::Process, validator: PaymentFiles::Formats::Stanza::ValidateConfig}
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