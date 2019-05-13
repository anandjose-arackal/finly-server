DEFINABLE_PROPERTY_MAP = {}
# This ensures all the masters are when reloading
Rails.application.reloader.after_class_unload do
  unless Rails.application.config.eager_load
    DEFINABLE_PROPERTY_MAP.clear
    # Rails.application.eager_load!
  end
end