class ExportManager::Master::Invoices::TallyExportBase < ExportManager::Master::Invoices::TallyExport
  attr_accessor :invoice

  def initialize(invoice)
    self.invoice = invoice
  end

  def configuration
    configuration = self.invoice.company&.tally_configuration&.invoice_voucher_configuration
    return {} unless configuration.present?

    configuration
  end

  def get_voucher
    generator = ::Tally::Generator.new(company_name: company_name)
    record = invoice.to_liquid
    voucher = generate_voucher(generator, record)
    add_ledgers(voucher, record)
    voucher
  end

  def self.call(invoice)
    new(invoice).get_voucher
  end
end
