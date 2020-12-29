class Masters::ExportResources::Ops::Index < Transactions::API
  step Resolver::Transactions::Load(model: ExportResource, paginate: false)
end
