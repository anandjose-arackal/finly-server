class Macros::V1::BudgetsController < BaseControllers::MacrosBase

  def index
    params[:route] = 'budgets.default'
    endpoint Resolver::Resolve
  end

  def count
    params[:route] = 'budgets.default'
    endpoint Resolver::Resolve
  end

  def new_sync_attempt
    endpoint Macros::ErpSyncs::Create, args: [
        params: params.to_unsafe_h,
        current_user: current_user,
        record_class: Budgets
    ]
  end

end