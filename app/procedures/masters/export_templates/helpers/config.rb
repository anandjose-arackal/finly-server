class Masters::ExportTemplates::Helpers::Config
  def self.export_formats
    ExportFormat.pluck(:value)
  end

  def self.resources
    ExportResource.pluck(:value)
  end
end
