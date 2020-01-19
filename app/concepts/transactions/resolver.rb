module Transactions::Resolver
  extend Dry::Container::Mixin

  # Todo deprecated
  # def self.Model(model, scope: :default, paginate: false, config: {})
  #   Transactions::Task.build id: "transactions.resolver.model" do |context, **|
  #     Resolve.model(context, model, scope, paginate, config)
  #   end
  # end

  # def self.Load(klass: nil, model: nil, builder: nil, scope: :default, paginate: false, filter: true, includes: [])
  #   Transactions::Task.build id: "transactions.resolver.model" do |context, flow_options, circuit_options|
  #     if model
  #       klass = model.resolver(scope)
  #     elsif builder
  #       klass = Trailblazer::Option(builder).(context, context, circuit_options)
  #     end
  #
  #     raise "Resolver is not defined correctly for #{circuit_options[:exec_context]&.class&.name}" unless klass.present?
  #
  #     Resolve.with(context, klass, paginate: paginate, filter: filter, includes: includes)
  #   end
  # end
  #
  # class Resolve
  #   def self.with(options, klass, paginate: false, filter: true, includes: [])
  #     options['model.records'] = klass.new(options[:current_user]).resolve(
  #         params: options[:params],
  #         paginate: paginate,
  #         filter: filter,
  #         includes: includes
  #     )
  #   end
  # end
  #
  # module ActiveRecordHelper
  #   extend ActiveSupport::Concern
  #
  #   class_methods do
  #     def resolver(scope = :default)
  #       Transactions::Resolver["#{event_channel}.#{scope.to_s}"]
  #     end
  #
  #     def resolve(user, scope: :default, params: {}, paginate: false, filter: true, includes: [])
  #       resolver(scope)&.new(user)&.resolve(params: params, paginate: paginate, filter: filter, includes: includes)
  #     end
  #   end
  #
  # end
  #
  # class Scope
  #   attr_reader :user
  #
  #   def self.entity(entity = NoObject, scope: :default)
  #     unless entity == NoObject
  #       @entity = entity
  #       Transactions::Resolver.register "#{entity.event_channel}.#{scope}", self
  #     end
  #     @entity
  #   end
  #
  #   def initialize(user)
  #     @user = user
  #   end
  #
  #   def app
  #     RequestStoreUtil.current_app
  #   end
  #
  #   def resolve(params: {}, filter: true, paginate: false, includes: [])
  #     collection = load params
  #     collection = filter collection, params if filter
  #     collection = paginate collection, params if paginate
  #     collection = include collection, includes if includes.present?
  #     collection
  #   end
  #
  #   def load(params)
  #     scope.all
  #   end
  #
  #   def filter(collection, params)
  #     collection.ransack(params[:q]).result(distinct: true)
  #   end
  #
  #   def paginate(collection, params)
  #     page = params[:page] || 1
  #     per_page = params[:per_page] || 30
  #     collection.paginate(page: page, per_page: per_page)
  #   end
  #
  #   def include(collection, includes)
  #     collection.includes(*includes) if includes.present?
  #     collection
  #   end
  # end

end