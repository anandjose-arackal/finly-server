# config_file_path = File.join(Rails.root, 'config', 'proselytism.yml')
# if File.exist?(config_file_path)
#   params = YAML.load_file(config_file_path)
#   Proselytism.config do |config|
#     params[Rails.env].each do |k, v|
#       config.send "#{k}=", v
#     end
#   end
# end
#
# Proselytism.config.log_level  ||= Rails.logger.level
# Proselytism.config.log_path   ||= File.join(Rails.root, 'log', "proselytism.log")
# Proselytism.config.logger     ||= Proselytism::Logger.new Proselytism.config.log_path, Proselytism.config.log_level