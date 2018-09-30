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
    init_config
    self.list = init_list
  end

  def init_config
    return if self.fields.blank?
    self.config = []
    self.fields.each do |field|
      conf = {}
      if field.is_a?(Hash)
        conf = {}
      elsif field.is_a?(Symbol)

      else
        # Do nothing
      end
    end
  end

  def init_list
    nil
  end

  def generate
    return nil if self.list.nil?
    self.list.each do |entry|

    end
  end

end