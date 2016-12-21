module Endpoints
  class Application < Rails::Application
    config.before_configuration do
      env_file = Rails.root.join('config', 'endpoint.yml').to_s

      if File.exists?(env_file)

        yaml_file = YAML.load_file(env_file)[Rails.env]
        base_url = yaml_file['base_url']
        yaml_file.each do |key, value|
          next if key == 'base_url'
          base = (value['base'] or base_url)
          ENV["#{key}_base"] = base
          ENV["#{key}_path"] = value['path']
        end # end YAML.load_file
      end # end if File.exists?
    end
  end
end