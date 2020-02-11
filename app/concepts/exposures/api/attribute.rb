class Exposures::API::Attribute

  attr_accessor :name, :includes, :record_attribute, :exposure, :block

  # Includes: Used for capturing the data points to be included to optimize the fetch for the current record
  def initialize(name, includes: [], record_attribute: false, exposure: false, &block)
    self.name = name
    self.includes = includes
    self.record_attribute = record_attribute
    self.exposure = exposure
    self.block = block
  end

  # Defines self as a method
  def define!
    lambda do |*args|
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
  end

  def as_json(options = {})
    {
        name: self.name
    }
  end

end