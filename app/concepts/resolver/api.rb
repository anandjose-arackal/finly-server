class Resolver::API
  include DynamicAttributes

  attr_reader :user
  class_attr :entity

  def self.call(options)
    params = options[:params]
    filter = params[:filter] || true
    paginate = params[:paginate] || false
    includes = params[:includes] || []
    self.new(options[:current_user])
        .resolve(params: params, filter: filter, paginate: paginate, includes: includes)
  end

  def initialize(user)
    @user = user
  end

  def app
    RequestStoreUtil.current_app
  end

  def resolve(params: {}, filter: true, paginate: false, includes: [])
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