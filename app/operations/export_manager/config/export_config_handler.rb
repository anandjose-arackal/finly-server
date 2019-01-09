class ExportManager::Config::ExportConfigHandler

  DEFAULT_CONFIG = {spreadsheet: true, pdf: true}

  def self.config_for(user, master)
    return {} if master.blank? or master.class.key.blank? or master.class.fields.blank? or user.blank?
    fields_arr = master.class.fields
    type = master.class.key
    if fields_arr.size == 1 and fields_arr.first.is_a?(Hash)
      fields = fields_arr.first
    else
      fields = {}
      fields_arr.each do |field|
        if field.is_a?(Hash)
          fields[field.keys.first] = field.values.first
        elsif field.is_a?(Symbol)
          fields[field] = DEFAULT_CONFIG
        end
      end
    end
    company_config = {}
    company_config_items = user.company.export_configs.with_field_name(type)
    company_config_items&.map {|item| company_config[item[:key]] = {spreadsheet: item[:spreadsheet], pdf: item[:pdf]}}
    fields.merge company_config
  end

end