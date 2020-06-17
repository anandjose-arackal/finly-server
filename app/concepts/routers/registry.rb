class Routers::Registry
  include DynamicAttributes

  class_attr :registry, default: {}

  def self.register(route, router = Router)
    registry[route] = router.new
  end

  def self.router(route)
    register(route) if route.present? and registry[route].blank?
    registry[route]
  end

  # Fixme: This is required to clear previous routes when the loader is loading the files in development env. Need to figure out a better way
  def self.routers
    @routers ||= [
        AutoComplete::Router,
        Filters::Router,
        IndexBuilder::Router,
        Resolver::Router,
    ]
  end

end