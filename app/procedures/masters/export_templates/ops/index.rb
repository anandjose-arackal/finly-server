class Masters::ExportTemplates::Ops::Index < Transactions::API
  include HasScope

  # allow users with following roles
  step Transactions::Authorization::Roles(:export_manager, :admin)
  # step :index!
  step Resolver::Transactions::Load(model: ExportTemplateNew)

  # def index!(options, current_user:, params:, **)
  #   # TODO: can we use resolver 'export_templates.default' instead of rewriting??
  #   options['export_templates'] = ExportTemplateNew.where('company_id = ? AND (created_by_id = ? AND personal = ?) OR (personal = ?)', current_user.company.id, current_user.id, true, false)

  #   # TODO: need to check filtering
  #   options['export_templates'] = apply_scopes(options['export_templates'], params)
  # end
end

# TODO: Using IndexBuilder is not working. Check!!

# class Masters::ExportTemplates::Ops::Index < IndexBuilder::API
#   system_subscription :vp
#   # permissions :item_master_manager, :inventory_manager, :auditor, :admin
#   resolver 'export_templates.default'
#   reference '{{record.id}}'

#   # Fixed column is always default true
#   column :name, fixed: true, sort: :name do
#     text value: :name, format: 'primary'
#   end
#   column :description, sort: :description do
#     text value: :description
#   end
#   column :format, sort: :description do
#     text value: :format
#   end
#   column :resource, sort: :description do
#     text value: :resource
#   end
#   column :query, sort: :description do
#     text value: :query
#   end
#   column :template, sort: :description do
#     text value: :template
#   end

#   column :created_at, sort: :created_at do
#     date value: :created_at
#   end

#   column :updated_at, sort: :updated_at do
#     date value: :updated_at
#   end

#   column :created_by, default: true, sort: :created_by_user_id, includes: [:created_by] do
#     user value: :created_by
#   end
# end
