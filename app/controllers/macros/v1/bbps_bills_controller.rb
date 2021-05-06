class Macros::V1::CreditNotesController < BaseControllers::MacrosBase

  def index
    params[:route] = 'utility_bills.default'
    endpoint Resolver::Resolve
  end

  def count
    params[:route] = 'utility_bills.default'
    endpoint Resolver::Resolve
  end

  def show
  end

  def update
  end

  def new_sync_attempt
    endpoint Macros::ErpSyncs::Create, args: [
        params: params.to_unsafe_h,
        current_user: current_user,
        record_class: BbpsBill
    ]
  end

end