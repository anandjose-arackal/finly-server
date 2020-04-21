class Resolver::Transactions
  include DynamicAttributes

  def self.Load(klass: nil, route: :route, model: nil, scope: :default, builder: nil, paginate: false, filter: true, includes: [])
    Transactions::Task.build id: "transactions.resolver.model" do |context, flow_options, circuit_options|
      route_path = nil
      if model
        route_path = model.resolver_route(scope)
      elsif builder
        route_path = Trailblazer::Option(builder).(context, context, circuit_options)
      elsif klass.blank?
        route = [route] unless route.respond_to?(:each)
        route_path = context[:params]&.dig(*route)
      end

      # route = [route] unless route.respond_to?(:each)
      # route_path = context[:params]&.dig(*route)

      raise "Resolver is not defined correctly for #{circuit_options[:exec_context]&.class&.name}" if klass.blank? and route_path.blank?

      Resolve.with(context, klass: klass, route: route_path, paginate: paginate, filter: filter, includes: includes)
    end
  end

  class Resolve
    def self.with(options, klass: nil, route: nil, paginate: false, filter: true, includes: [])
      dispatch_params = {
          params: options[:params],
          paginate: paginate,
          filter: filter,
          includes: includes
      }
      if klass.present?
        options['model.records'] = klass.new(options[:current_user]).resolve(dispatch_params)
      elsif route.present?
        options['model.records'] = Resolver::Router.dispatch(route, current_user: options[:current_user], params: dispatch_params)
      else
        raise 'Klass or Route not provided for resolving'
      end
    end
  end

end