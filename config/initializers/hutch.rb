path = "#{Rails.root}/config/hutch.yml"
if File.exists?(path)
  values = YAML.load_file(path)
  if values.present?
    values.each do |key, value|
      next unless key.present?

      Hutch::Config.set(key.to_sym, value)
    end
  end
end