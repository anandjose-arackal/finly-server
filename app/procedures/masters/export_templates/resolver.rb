class Masters::ExportTemplates::Resolver < Resolver::API
  entity ExportTemplateNew

  def load(params)
    ExportTemplateNew.where('company_id = ? AND (created_by_id = ? AND personal = ?) OR (personal = ?)', user.company.id, user.id, true, false)
  end
end
