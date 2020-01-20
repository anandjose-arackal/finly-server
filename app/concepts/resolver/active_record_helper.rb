module Resolver::ActiveRecordHelper
  extend ActiveSupport::Concern

  class_methods do
    def resolver(scope = :default)
      Resolver::Router["#{event_channel}.#{scope.to_s}"]&.first&.klass
    end

    def resolve(user, scope: :default, params: {}, paginate: false, filter: true, includes: [])
      resolver(scope)&.klass&.new(user)&.resolve(params: params, paginate: paginate, filter: filter, includes: includes)
    end
  end

end
