class ImportJobs::Ops::Template < Transactions::API
  pass :process_template

  def process_template(context, params:, current_user:, **)
    op = ImportJobs::Router.dispatch("templates.#{params['route']}", {params: {route: params['route']}, current_user: current_user})
    context['template_url'] = op['template_url']
    true
  end
end