class Masters::ExportTemplates::Helpers::Config
  def self.export_formats
    %w[csv xls json xml]
  end

  def self.resources
    %w[
      invoice_line_items
    ]
  end
end
