class Masters::ExportTemplates::Ops::Show < Transactions::API
  step Model(ExportTemplateNew, :find_by)
  step Policy::Pundit(Masters::ExportTemplates::Policy, :show?)
end
