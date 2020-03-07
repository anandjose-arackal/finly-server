class ExportManager::Builders::Tally < ExportManager::API
  include MathUtil

  type :spreadsheet

  class_attr :tally_config_key

  configurable false

  def configuration
    raise "tally_config_key not defined for #{self.class.name}" unless self.class.tally_config_key.present?
    return {} unless user&.company&.tally_configuration.present?

    user.company.tally_configuration&.send(self.class.tally_config_key)
  end

  def company_name
    configuration[:company_name]
  end

  def generator
    @generator ||= ::Tally::Generator.new(company_name: company_name)
  end

  def generate
    data.find_each do |record|
      record = record.to_liquid
      voucher = generate_voucher(generator, record)
      add_ledgers(voucher, record)
    end

    file_data = generator.as_xml
    file = Paperclip::Tempfile.new(['export', '.xml'])
    open(file.path, 'wb') {|f| f.write file_data}

    if file
      save_attachment file
      success!
    else
      failure!
    end
  end

  def generate_voucher(generator, record)
    raise "Voucher generation is not implemented for #{self.class.name}"
  end

  def add_ledgers(voucher, record)
    raise "Voucher ledger generation has not been defined for #{self.class.name}"
  end

end