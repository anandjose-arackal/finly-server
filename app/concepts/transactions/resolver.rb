class Transactions::Resolver

  def self.Model(model, scope: :default, filter: false, paginate: false, includes: [])
    Transactions::Task.build id: "transactions.resolver.model" do |context, **|
      Resolve.with(context, model, scope, filter, paginate, includes)
    end
  end

  class Resolve
    def self.with(options, model, scope, filter, paginate, includes)
      options['model.index'] = model.resolve(
          options[:current_user],
          params: options[:params],
          scope: scope,
          filter: filter,
          paginate: paginate,
          includes: includes
      )
    end
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve(params: {}, filter: false, paginate: false, includes: [])
      collection = load params
      collection = filter collection, params if filter
      collection = paginate collection, params if paginate
      collection = include collection, includes if includes.present?
      collection
    end

    def load(params)
      scope.all
    end

    def filter(collection, params)
      collection.ransack(params[:q]).result(distinct: true)
    end

    def paginate(collection, params)
      page = params[:page] || 1
      per_page = params[:per_page] || 30
      collection.paginate(page: page, per_page: per_page)
    end

    def include(collection, includes)
      collection.includes(*includes) if includes.present?
      collection
    end
  end

end