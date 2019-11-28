class Analytics::Mapper
  include Events::Consumer
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
    return @fields unless @fields.nil?
    @fields ||= [] #default_fields
    set_defaults
  end

  def self.olap_model
    fact || dimension
  end

  def self.set_defaults
    field :finly_ref_id, :id
    field :finly_ref_created_at, :created_at
    field :finly_ref_updated_at, :updated_at
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

    validate_fields
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

      validates :finly_ref_id, presence: true
      validates :finly_ref_created_at, presence: true
      validates :finly_ref_updated_at, presence: true
    end
  end

  def self.validate_fields
    finly_ref_id = fields.select {|f| f[:primary_key] == :finly_ref_id}
    raise "finly_ref_id is not defined for #{self.name}" unless finly_ref_id.present?
    finly_ref_created_at = fields.select {|f| f[:primary_key] == :finly_ref_created_at}
    raise "finly_ref_created_at is not defined for #{self.name}" unless finly_ref_created_at.present?
    finly_ref_updated_at = fields.select {|f| f[:primary_key] == :finly_ref_updated_at}
    raise "finly_ref_updated_at is not defined for #{self.name}" unless finly_ref_updated_at.present?
  end

  def self.events(*list)
    raise "Event is already defined" if @events.present?

    @events = list
    list.each do |event|
      Class.new(self) do
        consumes_event! event,
                        consumer_key: "analytics.synchronizer.#{event}",
                        name: "Analytics Synchronizer for #{event}",
                        options: {sync: false}
      end
    end
  end

  def on_event(user, payload)
    mapper = self.class
    input = mapper.input.call(user, payload)
    input = [input] unless input.respond_to?(:each)
    input.each do |record|
      sync = Analytics::Synchronizer.(params: {record: record, mapper: mapper})
      unless sync.success?
        # Todo log failure with reason
        raise "Sync Error: #{sync.errors}}"
      end
    end
  end
end