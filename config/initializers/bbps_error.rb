require 'yaml'
BBPS_ERROR_MESSAGES = YAML.load_file("#{Rails.root}/config/bbps_error.yml")
# BBPS_ERROR_MESSAGES = YAML.load_file(File.expand_path("config/bbps_error.yml"))