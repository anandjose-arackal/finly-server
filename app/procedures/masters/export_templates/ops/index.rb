class Masters::ExportTemplates::Ops::Index < Transactions::API
  include HasScope

  has_scope :filter_resource, as: :resource
  has_scope :filter_default, type: :boolean, as: :default
  has_scope :filter_route, as: :route

  # allow users with following roles
  # step Transactions::Authorization::Roles(:export_manager, :admin)
  step :index!
  # step Resolver::Transactions::Load(model: ExportTemplateNew)

  def index!(options, current_user:, params:, **)
    options['model.records'] = Resolver::Router.dispatch("export_templates.default", { current_user: current_user, params: params })

    options['model.records'] = apply_scopes(options['model.records'], params)
  end
end
