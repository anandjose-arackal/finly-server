# config/initializers/imgkit.rb
IMGKit.configure do |config|
  config.wkhtmltoimage = '~/.rbenv/shims/'
end