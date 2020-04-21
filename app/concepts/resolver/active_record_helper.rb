module Resolver::ActiveRecordHelper
  extend ActiveSupport::Concern

  class_methods do
    def resolver_route(scope = :default)
      "#{event_channel}.#{scope.to_s}"
    end

    def resolve(user, scope: :default, params: {}, paginate: false, filter: true, includes: [])
      Resolver::Router.dispatch(resolver_route(scope), current_user: user, params: params.merge({paginate: paginate, filter: filter, includes: includes}))
    end
  end

end
