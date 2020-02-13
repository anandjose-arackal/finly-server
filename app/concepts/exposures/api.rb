class Exposures::API < Liquid::Drop
  include DynamicAttributes
  include Exposures::PreLoader
  include Exposures::TemplateProcessor

  class_attr :attributes, default: {}

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
  #   - exposure: Flag if the result should be converted to a Exposure::API
  def self.attribute(name, includes: [], record_attribute: false, exposure: false, data_type: :text, &block)
    raise "#{name} is already defined for class #{self.name}" if exists?(name)
    raise "#{name} : Non-record attributes require a block for fetching the data" unless record_attribute or block_given?

    if record_attribute and exposure
      include_key = record_attribute.is_a?(Symbol) ? record_attribute : name

      includes << include_key unless includes.include?(name)
    end

    attributes[name] = Attribute.new(
        {
            name: name,
            includes: includes,
            record_attribute: record_attribute,
            exposure: exposure,
            data_type: data_type,
            block: block
        }
    )
    class_eval &attributes[name].define!
  end

  def initialize(object)
    @object = object
  end

  def object
    @object
  end

  alias_method :record, :object

end