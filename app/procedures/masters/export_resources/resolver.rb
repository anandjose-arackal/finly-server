class Masters::ExportResources::Resolver < Resolver::API
  entity ExportResource

  def load(params)
    ExportResource.all
  end
end
