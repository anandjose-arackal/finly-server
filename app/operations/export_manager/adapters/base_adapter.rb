class ExportManager::Adapters::BaseAdapter
  cattr_accessor :key, :fields

  attr_accessor :user, :params, :list, :config

  ADAPTERS = {}

  def self.handle(key)
    self.key = key
    ADAPTERS[key] = self
  end

  def self.fields(fields)
    self.fields = fields
  end

  def initialize(user, params)
    self.user = user
    self.params = params
    self.config = init_config
    self.list = init_list
  end

  def init_list
    # To be written by every adapter
  end

  def init_config
    return {} if self.params.blank? or self.params[:type].blank?
    type = self.params[:type]
    fields_arr = self.fields
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

  def generate
    headers = load_headers
    contents = load_contents
    Exporter::Spreadsheet.new(user, {headers: headers, contents: contents})
  end

  def load_headers
    headers = []
    self.config.each do |field, conf|
      headers << (conf[:label] || field.to_s.humanize)
    end
    headers
  end

  def load_contents
    contents = []
    return contents if self.list.nil?
    self.list.each do |entry|
      self.config.each do |field, conf|
        if conf[:spreadsheet]
          if self.respond_to?(field)
            contents << self.send(field, entry)
          else
            raise "#{field} not defined for exporter #{self.class.name}"
          end
        end
      end
    end
    contents
  end

end