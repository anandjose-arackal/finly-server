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

  def self.routers
    @routers ||= [
        AutoComplete::Router
    ]
  end

  def self.reload_all
    routers.each do |router|
      router.clear_map
    end
    Dir.glob(Rails.root.join("app/routes/**/*.rb")).each {|f| load f}
  end

end