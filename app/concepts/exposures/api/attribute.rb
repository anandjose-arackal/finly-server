class Exposures::API::Attribute

  attr_accessor :name, :includes, :record_attribute, :exposure, :data_type, :block

  # Includes: Used for capturing the data points to be included to optimize the fetch for the current record
  def initialize(name:, includes: [], record_attribute: false, exposure: false, data_type: nil, block: nil)
    self.name = name
    self.includes = includes
    self.record_attribute = record_attribute
    self.exposure = exposure
    self.data_type = data_type
    self.block = block
  end

  # Defines self as a method
  def define!
    record_attribute = self.record_attribute
    name = self.name
    block = self.block
    exposure = self.exposure
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

        return value unless exposure
        return value if value.class <= Exposures::API
        raise "#{value.class.name} does not have an exposure defined" unless value.respond_to?(:to_exposure)
        return value.to_exposure
      end
    end
  end

  def as_json(options = {})
    {
        name: self.name
    }
  end

end