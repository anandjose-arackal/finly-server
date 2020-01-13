class ExportTemplates::Helpers::Config

  PROCESSORS = {
      spreadsheet: {
          contract: ExportTemplates::Spreadsheet::Contract,
          file_builder: ExportTemplates::Spreadsheet::FileBuilder
      },
      tally_invoice_voucher: {
          contract: ExportTemplates::TallyInvoiceVoucher::Contract,
          file_builder: ExportTemplates::TallyInvoiceVoucher::FileBuilder
      }
  }.with_indifferent_access

  def self.types
    PROCESSORS.keys
  end

  def contract_for(type)
    load type, :contract
  end

  def file_builder_for(type)
    load type, :file_builder
  end

  def load(type, key)
    PROCESSORS&.dig(type, key).new
  end

end