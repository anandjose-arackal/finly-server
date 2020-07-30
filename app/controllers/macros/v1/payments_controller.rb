class Macros::V1::PaymentsController < BaseControllers::MacrosBase

  def index
    params[:route] = 'payments.default'
    endpoint Resolver::Resolve
  end

  def count
    params[:route] = 'payments.default'
    endpoint Resolver::Resolve
  end

  def new_sync_attempt
    endpoint Macros::ErpSyncs::Create, args: [
        params: params.to_unsafe_h,
        current_user: current_user,
        record_class: PaymentTicket
    ]
  end

end
