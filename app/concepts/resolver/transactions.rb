class Resolver::Transactions
  include DynamicAttributes

  def self.Load(klass: nil, model: nil, builder: nil, scope: :default, paginate: false, filter: true, includes: [])
    Transactions::Task.build id: "transactions.resolver.model" do |context, flow_options, circuit_options|
      if model
        klass = model.resolver(scope)
      elsif builder
        klass = Trailblazer::Option(builder).(context, context, circuit_options)
      end

      raise "Resolver is not defined correctly for #{circuit_options[:exec_context]&.class&.name}" unless klass.present?

      Resolve.with(context, klass, paginate: paginate, filter: filter, includes: includes)
    end
  end

  class Resolve
    def self.with(options, klass, paginate: false, filter: true, includes: [])
      options['model.records'] = klass.new(options[:current_user]).resolve(
          params: options[:params],
          paginate: paginate,
          filter: filter,
          includes: includes
      )
    end
  end

end