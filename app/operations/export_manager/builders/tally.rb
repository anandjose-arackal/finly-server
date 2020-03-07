class ExportManager::Builders::Tally < ExportManager::API
  include DSL
  include MathUtil

  type :tally

  class_attr :tally_config_key

  def self.config
    {}
  end

  def tally_config
    return {} unless self.class.tally_config_key.present?
    return {} unless user&.company&.tally_configuration.present?

    user.company.tally_configuration&.send(self.class.tally_config_key)
  end

  def company_name
    tally_config[:company_name]
  end

  def generator
    @generator ||= ::Tally::Generator.new(company_name: company_name)
  end

  def generate
    data.find_each do |record|
      record = record.to_liquid
      voucher = generate_voucher(record)
      generator.add_voucher(voucher) if voucher.present?
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

  def generate_voucher(record)
    raise "Voucher generation is not implemented for #{self.class.name}"
  end

  def add_ledgers(voucher, record)

  end

end