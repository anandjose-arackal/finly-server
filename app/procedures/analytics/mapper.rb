require "reform/form/validation/unique_validator"

module Analytics::Mapper
  extend ActiveSupport::Concern

  included do
    include Events::Consumer
    include DynamicAttributes

    class_attr :input, default: -> (user, payload) { payload[:record] }

  end

  class_methods do
    def transaction_model(klass = NoObject)
      unless klass == NoObject
        @transaction_model = klass
        Analytics::Master.register @transaction_model, self
      end
      @transaction_model
    end

    def field_mappings
      return @field_mappings unless @field_mappings.nil?
      @field_mappings ||= []
      set_defaults
    end

    def set_defaults
      map :finly_ref_id, :id
      map :finly_ref_created_at, :created_at
      map :finly_ref_updated_at, :updated_at
    end

    def map(primary_key, foreign_key = nil, &block)
      raise "transaction_model is not defined" if transaction_model.nil?

      prop = {primary_key: primary_key}
      if block_given?
        prop[:block] = block
      elsif foreign_key.present?
        prop[:foreign_key] = foreign_key
      elsif transaction_model.new.respond_to?(primary_key)
        prop[:foreign_key] = primary_key
      else
        # Check if the method exists in the transaction_model
        raise "#{self.name}: #{transaction_model} does not respond to field #{primary_key}"
      end
      field_mappings << prop
    end

    def contract
      return @contract if @contract

      validate_field_mappings
      klass = self
      @contract = Class.new(Transactions::Contract) do
        klass.field_mappings.each do |field|
          property field[:primary_key], deserialize(-> (input, represented, record:, **) do
            if field.has_key?(:block)
              # Pick value from block
              value = field[:block].call(input, record)
            elsif field[:foreign_key].present? and record.respond_to?(field[:foreign_key])
              # Pick value from the active_record by passing the field key
              value = record.send(field[:foreign_key])
            else
              # Raise exception
              raise "#{self.name}: Value for field #{field[:primary_key]} not found for #{transaction_model}"
            end
            represented.send("#{field[:primary_key]}=", value)
          end)
        end

        validates :finly_ref_id, presence: true, unique: true
        validates :finly_ref_created_at, presence: true
        validates :finly_ref_updated_at, presence: true
      end
    end

    def validate_field_mappings
      finly_ref_id = field_mappings.select { |f| f[:primary_key] == :finly_ref_id }
      raise "finly_ref_id is not defined for #{self.name}" unless finly_ref_id.present?
      finly_ref_created_at = field_mappings.select { |f| f[:primary_key] == :finly_ref_created_at }
      raise "finly_ref_created_at is not defined for #{self.name}" unless finly_ref_created_at.present?
      finly_ref_updated_at = field_mappings.select { |f| f[:primary_key] == :finly_ref_updated_at }
      raise "finly_ref_updated_at is not defined for #{self.name}" unless finly_ref_updated_at.present?
    end

    def events(*list)
      raise "Event is already defined" if @events.present?

      @events = list
      list.each do |event|
        Class.new(self) do
          consumes_event!(event, consumer_key: "analytics.synchronizer.#{event}", name: "Analytics Synchronizer for #{event}", options: {sync: false})
        end
      end
    end

    def sync(after: nil)
      Analytics::Master.sync(self, after: after)
    end
  end

  def on_event(user, payload)
    olap_model = self.class
    input = olap_model.input.call(user, payload)
    input = [input] unless input.respond_to?(:each)
    input.each do |record|
      sync = Analytics::Synchronizer.(params: {record: record, olap_model: olap_model})
      unless sync.success?
        # Todo log failure with reason
        raise "Sync Error: #{sync.errors}}"
      end
    end
  end
end