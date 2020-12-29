class Masters::ExportFormats::Ops::Index < Transactions::API
  step Resolver::Transactions::Load(model: ExportFormat, paginate: false)
end
