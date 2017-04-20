class YamlUtils

  def self.load_yaml_erb(path_to_file, binding_params = {})
    return nil if path_to_file.blank?
    b = nil
    if binding_params.present?
      b = binding
      binding_params.each do |key, val|
        b.local_variable_set(key, val)
      end
    end
    loaded_erb = ERB.new(File.read("#{Rails.root}/config/data/menu_data_cards.yml.erb"))
    if b.present?
      loaded_erb = loaded_erb.result(b)
    end
    YAML.load(loaded_erb)
  end

end