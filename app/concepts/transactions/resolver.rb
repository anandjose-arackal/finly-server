class Transactions::Resolver
  extend Dry::Container::Mixin

  # Todo deprecated
  # def self.Model(model, scope: :default, paginate: false, config: {})
  #   Transactions::Task.build id: "transactions.resolver.model" do |context, **|
  #     Resolve.model(context, model, scope, paginate, config)
  #   end
  # end

  def self.Load(klass: nil, model: nil, builder: nil, scope: :default, config: {})
    Transactions::Task.build id: "transactions.resolver.model" do |context, **|
      if klass
        Resolve.constant(context, klass, config)
      elsif model
        Resolve.model(context, model, scope, config)
      elsif builder
        Resolve.builder(context, builder, config)
      else
        raise 'Resolver is not defined correctly'
      end
    end
  end

  class Resolve
    def self.model(options, model, scope, config)
      result = model.resolve(
          options[:current_user],
          params: options[:params],
          scope: scope,
          config: config
      )
      unless result.success?
        # Todo
        return
      end
      options['model.records'] = result[:records]
    end

    def self.constant(options, klass, config)
      result = klass.new(options[:current_user]).resolve(
          params: options[:params],
          config: config
      )
      unless result.success?
        # Todo
        return
      end
      options['model.records'] = result[:records]
    end

    def self.builder(options, builder, config)
      klass = self.send(builder)
      constant(options, klass, config)
    end
  end

  module ActiveRecordHelper
    extend ActiveSupport::Concern

    class_methods do
      def resolver(scope = :default)
        Transactions::Resolver["#{event_channel}.#{scope.to_s}"]
      end

      def resolve(user, scope: :default, params: {}, config: {})
        resolver(scope)&.(params: params, config: config, current_user: user)
      end
    end

  end

  class Scope < Transactions::API

    class_attr :model
    class_attr :scope, default: :default

    def self.entity(model = nil, scope: :default)
      if model
        raise "Event Channel is not defined for #{self.model.name}" unless model.event_channel.present?

        model(model)
        Transactions::Resolver.register("#{model.event_channel}.#{scope}", self)
      end
      raise "Model is not defined for #{self.name}" unless model.present? unless model

      model
    end

    step :init
    step :fetch
    pass :filter
    pass :paginate
    pass :include

    # def initialize(user)
    #   @user = user
    # end

    def entity
      self.class.entity
    end

    def app
      RequestStoreUtil.current_app
    end

    def init(context, options)
      true
    end

    def fetch(context, current_user:, params:, **)
      result = resolve(current_user, params)
      if result.class <= Dry::Monads::Result
        return result unless result.success?

        records = result.success
      else
        records = result
      end

      context[:records] = records
      true
    end

    def resolve(current_user, params)
      raise "Load is not implemented for #{self.name}"
    end

    def filter(context, records:, params:, config: {}, **)
      return true unless config[:do_not_filter] == true

      context[:records] = records.ransack(params[:q]).result(distinct: true)
      true
    end

    def paginate(context, records:, params:, config: {}, **)
      return true unless config[:do_not_paginate] == true

      page = params[:page] || 1
      per_page = params[:per_page] || config[:per_page] || 30
      context['records.paginated'] = records.paginate(page: page, per_page: per_page)
    end

    def include(context, includes: [], **)
      return true unless includes.present?

      context['records.paginated'] = context['records.paginated']&.includes(*includes)
      context[:records] = context[:records]&.includes(*includes)
      true
    end

  end

end