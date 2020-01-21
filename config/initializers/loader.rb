# Clear and reload all routers
Loader.watch! "Routes Loader" do
  Routers::Registry.routers.each do |router|
    router.clear_map
  end
  Dir.glob(Rails.root.join("app/routes/**/*.rb")).each {|f| load f}
end

Loader.watch! "Forms Types", dir: 'app/concepts/forms/definitions/types/**/*.rb'