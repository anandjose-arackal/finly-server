OBSERVERS = {}
OBSERVERS_MASTER = {}

Rails.application.reloader.after_class_unload do
  if Rails.application.config.eager_load
    Observer::Reset.()
    Rails.application.eager_load!
  end
end