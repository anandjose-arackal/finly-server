class Analytics::Mapper
  include DynamicAttributes

  class_attr :fields, default: []
  class_attr :model
  class_attr :events
  class_attr :fact
  class_attr :dimension
  class_attr :input, default: -> (user, payload) { payload[:record] }

  def self.fields
    return @fields if @fields.present?
    @fields = reset_fields
  end

  def self.reset_fields
    [
        {
            primary_key: :finly_ref_id,
            foreign_key: :id
        }
    ]
  end

  def self.field(primary_key, foreign_key=nil,  &block)
    raise "Model is not defined" if model.nil?

    prop = {primary_key: primary_key}
    if block_given?
      prop[:block] = block
    elsif foreign_key.present?
      prop[:foreign_key] = foreign_key
    elsif model.new.respond_to?(primary_key)
      prop[:foreign_key] = primary_key
    else
      # Check if the method exists in the model
      raise "#{self.name}: #{model} does not respond to field #{primary_key}"
    end
    fields << prop
  end

  def self.contract
    return @contract if @contract

    @contract = Class.new(Transactions::Contract) do
      fields.each do |field|
        property field[:primary_key], deserialize(-> (input, represented, record:, **) do
          if field.has_key?(:block)
            # Pick value from block
            value = field[:block].call(input, record)
          elsif field[:foreign_key].present? and record.respond_to?(field[:foreign_key])
            # Pick value from the active_record by passing the field key
            value = record.send(field[:foreign_key])
          else
            # Raise exception
            raise "#{self.name}: Value for field #{field[:primary_key]} not found for #{model}"
          end
          represented.send("#{field[:primary_key]}=", value)
        end)
      end
    end
  end

end