class Transactions::Contracts::PreProcessors::Deserializer < Transactions::Contracts::PreProcessors::Base

  register!

  def run!
    return false unless options[:deserializer].present?

    unless options[:deserializer].is_a?(Hash) and options[:deserializer][:parse_pipeline].present?
      options[:deserializer] = deserialize(args[:contract], options[:deserializer])
    end
    true
  end

  def deserialize(contract, deserializer)
    klass = contract
    {
        parse_pipeline: ->(*) {
          ->(input, represented:, **) {
            if deserializer.is_a?(Symbol)
              klass.send(deserializer, input&.with_indifferent_access, represented, **input)
            elsif deserializer.is_a?(Class)
              # Todo
            else
              deserializer.call(input&.with_indifferent_access, represented, **input&.symbolize_keys)
            end
          }
        }
    }
  end

end
