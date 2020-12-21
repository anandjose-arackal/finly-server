class Masters::ExportFormats::Resolver < Resolver::API
  entity ExportFormat

  def load(params)
    ExportFormat.all
  end
end
