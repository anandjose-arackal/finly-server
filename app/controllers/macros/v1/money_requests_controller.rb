class Macros::V1::MoneyRequestsController < BaseControllers::MacrosBase

    def index
      params[:route] = 'money_requests.default'
      endpoint Resolver::Resolve
    end
  
    def count
      params[:route] = 'money_requests.default'
      endpoint Resolver::Resolve
    end
  
    def show
      # Todo
    end
  
    def update
      # Todo
    end
  
    def new_sync_attempt
      endpoint Macros::ErpSyncs::Create, args: [
          params: params.to_unsafe_h,
          current_user: current_user,
          record_class: MoneyRequest
      ]
    end
  
  end
  