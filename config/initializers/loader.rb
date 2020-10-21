Loader.watch! "Searchkick clear loaded models" do
  # Searchkick appends the models everytime it is reloaded. This creates a lot of duplicate models being captured.
  # This is prevent that behavior
  Searchkick.models.clear
  ApplicationRecord.descendants.each do |model|
    Searchkick.models << model if model.respond_to?(:searchkick_api)
  end
end
Loader.watch! "Actions Manager Actions", dir: "app/concepts/action_manager/actions/**/*.rb"
Loader.watch! "Forms Types", dir: 'app/concepts/forms/api/entity/types/**/*.rb'
Loader.watch! "Choices", dir: 'app/concepts/choices/builders/**/*.rb'

Loader.watch! "Form Contract Transformers", dir: "app/concepts/forms/generators/contracts/entity_builder/validations/**/*.rb"
Loader.watch! "Form Contract Transformers", dir: "app/concepts/index_builder/content_types/**/*.rb"

Loader.watch! "Transaction Contract PreProcessors", dir: "app/concepts/transactions/contracts/pre_processors/**/*.rb"

Loader.watch! "Menu Masters", dir: "app/procedures/menu/masters/**/*.rb"

# Clear and reload all routers
Loader.watch! "Routes Loader" do
  Routers::Registry.routers.each do |router|
    router.clear_map
  end
  Dir.glob(Rails.root.join("app/routes/**/*.rb")).each { |f| load f }
end

Loader.watch! "Bullet Train" do
  config = Rails.application.config_for(:feature_flipper)&.with_indifferent_access
  if config.dig('api_key').present? and config.dig('url').present?
    Rails.configuration.bullet_train = BulletTrain.new(api_key: config['api_key'], url: config['url'])
  end
end