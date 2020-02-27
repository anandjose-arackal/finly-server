path = "#{Rails.root}/config/hutch.yml"
values = YAML.load_file(path)
values.each do |key, value|
  Hutch::Config.set(key, value)
end