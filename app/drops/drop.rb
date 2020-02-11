class Drop < Liquid::Drop
  include DynamicAttributes

  class_attr :attributes, default: {}

  # Generates the includes configuration based on the selected fields
  def self.includes_config_for(*fields)
    config = []
    fields.each do |field|
      includes = attributes[field]&.dig(:includes)
      next unless includes.present?

      config += includes
    end
    config.uniq
  end

  # Check if the attribute is defined
  def self.exists?(name)
    attributes[name].present?
  end

  # create a new method with the respective name
  # add the attribute to the list of attributes
  # Available options:
  #   - includes: Array: List of models to include
  #   - record_attribute: If the attribute can be fetched directly from the model.
  #       All record attributes that are data providers will be added to the include list by default
  #   - data_provider: Flag if the result should be converted to a liquid_drop
  def self.attribute(name, includes: [], record_attribute: false, data_provider: false, &block)
    raise "#{name} is already defined for class #{self.name}" if exists?(name)
    raise "#{name} : Non-record attributes require a block for fetching the data" unless record_attribute or block_given?

    if record_attribute and data_provider
      include_key = record_attribute.is_a?(Symbol) ? record_attribute : name

      includes << include_key unless includes.include?(name)
    end

    attributes[name] = {
        name: name,
        includes: includes,
        record_attribute: record_attribute,
        data_provider: data_provider,
        block: block
    }
    define_method name do
      if record_attribute
        if record_attribute.is_a?(Symbol)
          value = record.send(record_attribute)
        else
          value = record.send(name)
        end
      else
        value = block.call
      end

      return value unless data_provider
      return value if value.class <= Drop
      return value.to_liquid
    end
  end

  def initialize(object)
    @object = object
  end

  def object
    @object
  end

  alias_method :record, :object

end