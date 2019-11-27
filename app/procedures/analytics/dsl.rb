class Analytics::DSL
  include DynamicAttributes

  class_attr :fields, default: []
  class_attr :fact
  class_attr :dimension
  class_attr :input, default: -> (user, payload) { payload[:record] }

  def self.model(klass = NoObject)
    unless klass == NoObject
      @model = klass
      Analytics::Master.register @model, self
    end
    @model
  end

  def self.fields
    return @fields if @fields.present?
    @fields ||= default_fields
  end

  def self.olap_model
    fact || dimension
  end

  def self.default_fields
    # Add finly_ref_id as a default field
    [
        {
            primary_key: :finly_ref_id,
            foreign_key: :id
        },
        {
            primary_key: :finly_ref_updated_at,
            foreign_key: :updated_at
        },
        {
            primary_key: :finly_ref_created_at,
            foreign_key: :created_at
        }
    ]
  end

  def self.field(primary_key, foreign_key = nil, &block)
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

    klass = self
    @contract = Class.new(Transactions::Contract) do
      klass.fields.each do |field|
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

  def self.events(*list)
    raise "Event is already defined" if @events.present?

    @events = list
    Analytics::Synchronizer.setup(self, list)
  end
end