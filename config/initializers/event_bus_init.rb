EVENT_BUS_MASTER = {}
EVENT_BUS_SUBSCRIBERS = {}
# This ensures all the masters are when reloading
Rails.application.reloader.after_class_unload do
  unless Rails.application.config.eager_load
    EVENT_BUS_SUBSCRIBERS.clear
    EVENT_BUS_MASTER.clear
    # Rails.application.eager_load!
  end
end