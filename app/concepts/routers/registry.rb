class Routers::Registry
  include DynamicAttributes

  class_attr :registry, default: {}

  # LOAD_PATHS = [
  #     'app/concepts/auto_complete/routes.rb'
  # ]

  def self.register(route, router = Router)
    registry[route] = router.new
  end

  def self.router(route)
    register(route) if route.present? and registry[route].blank?
    registry[route]
  end

  # LOAD_PATHS.each do |path|
  #   Dir[path].each { |f| load f }
  # end

end