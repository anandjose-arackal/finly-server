require "reform/form/validation/unique_validator"

class Analytics::Mapper::ContractBuilder

  def self.build(klass)
    Class.new(Transactions::Contract) do
      klass.field_mappings.each do |field|
        property field[:primary_key], deserializer: -> (input, represented, record:, **) do
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
        end
      end

      validates :finly_ref_id, presence: true, unique: true
      validates :finly_ref_created_at, presence: true
      validates :finly_ref_updated_at, presence: true
    end
  end

end