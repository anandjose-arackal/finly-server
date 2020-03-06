Loader.watch! "Forms Types", dir: 'app/concepts/forms/api/entity/types/**/*.rb'
Loader.watch! "Forms Scopes", dir: 'app/concepts/forms/choice_providers/**/*.rb'

Loader.watch! "Form Contract Transformers", dir: "app/concepts/forms/generators/contracts/entity_builder/validations/**/*.rb"
Loader.watch! "Form Contract Transformers", dir: "app/concepts/index_builder/content_types/**/*.rb"

Loader.watch! "Transaction Contract PreProcessors", dir: "app/concepts/transactions/contracts/pre_processors/**/*.rb"

# Clear and reload all routers
Loader.watch! "Routes Loader" do
  Routers::Registry.routers.each do |router|
    router.clear_map
  end
  Dir.glob(Rails.root.join("app/routes/**/*.rb")).each {|f| load f}
end