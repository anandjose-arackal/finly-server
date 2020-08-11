class Masters::ExportTemplates::Helpers::Config
  def self.export_formats
    # TODO: move these to DB??
    %w[csv xls json xml]
  end

  def self.resources
    # TODO: move these to DB??
    %w[
      invoice_line_items
    ]
  end
end
