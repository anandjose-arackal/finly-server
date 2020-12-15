class Masters::ExportTemplates::Resolver < Resolver::API
  entity ExportTemplateNew

  def load(params)
    ExportTemplateNew.includes(:role_mappings).references(:role_mappings).where('company_id = ? AND ((created_by_id = ? AND personal = ?) OR (personal = ?)) AND (user_role_id is null OR user_role_id in (?))', user.company.id, user.id, true, false, user.policy_user_roles.pluck('user_role_id').uniq)
  end
end
