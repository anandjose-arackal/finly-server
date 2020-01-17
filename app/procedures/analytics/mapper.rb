require "reform/form/validation/unique_validator"

module Analytics::Mapper
  extend ActiveSupport::Concern

  included do
    include Events::Consumer
    include DynamicAttributes

    class_attr :is_sync, default: false
    class_attr :transaction_model
    class_attr :field_mappings
    class_attr :olap_model
    class_attr :required_relationships, default: []
    class_attr :input, default: -> (user, payload) { payload[:record] }

    define_singleton_method :field_mappings do
      next self.attribute_field_mappings unless self.attribute_field_mappings.nil?
      self.attribute_field_mappings ||= []
      set_defaults
      self.attribute_field_mappings
    end

    define_singleton_method :transaction_model do |klass = NoObject|
      unless klass == NoObject
        Analytics::Master.register klass, self
        self.attribute_transaction_model = klass
      end
      self.attribute_transaction_model
    end
  end

  class_methods do
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
      @contract = ContractBuilder.build(self)
    end

    def validate_field_mappings
      finly_ref_id = field_mappings.select { |f| f[:primary_key] == :finly_ref_id }
      raise "finly_ref_id is not defined for #{self.name}" unless finly_ref_id.present?
      finly_ref_created_at = field_mappings.select { |f| f[:primary_key] == :finly_ref_created_at }
      raise "finly_ref_created_at is not defined for #{self.name}" unless finly_ref_created_at.present?
      finly_ref_updated_at = field_mappings.select { |f| f[:primary_key] == :finly_ref_updated_at }
      raise "finly_ref_updated_at is not defined for #{self.name}" unless finly_ref_updated_at.present?
    end

    def sync!
      is_sync(true)
    end

    def sync?
      is_sync
    end

    def events(*list)
      raise "Event is already defined" if @events.present?

      @events = list
      @events.each do |event|
        EventHandler.build(self, event)
      end
    end

    def sync(after: nil)
      Analytics::Master.sync(self, after: after)
    end
  end

  def build_contract(record)
    self.class.contract.new(self)
  end

  def in_sync?(record, payload = {})
    finly_ref_updated_at == record.updated_at
  end

end