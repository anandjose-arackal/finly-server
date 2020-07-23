# config/initializers/imgkit.rb
IMGKit.configure do |config|
  config.wkhtmltoimage = '/usr/bin/wkhtmltoimage'
end