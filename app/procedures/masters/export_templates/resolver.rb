class Masters::ExportTemplates::Resolver < Resolver::API
  entity ExportTemplateNew

  def load(params)
    return [] unless user.admin?
    ExportTemplateNew.includes(:role_mappings).references(:role_mappings).where('export_template_news.company_id = ? AND ((export_template_news.created_by_id = ? AND export_template_news.personal = ?) OR (export_template_news.personal = ?)) AND (user_role_id is null OR user_role_id in (?))', user.company.id, user.id, true, false, user.user_roles.pluck('user_role_id').uniq)
  end
end
