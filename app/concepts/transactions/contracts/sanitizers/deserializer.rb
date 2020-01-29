class Transactions::Contracts::Sanitizers::Deserializer < Transactions::Contracts::Sanitizers::Base

  register!

  def self.run(contract, type,name, options, block)
    return unless options[:deserializer].present?

    unless options[:deserializer].is_a?(Hash) and options[:deserializer][:parse_pipeline].present?
      options[:deserializer] = deserialize(contract, options[:deserializer])
    end
  end

  def self.deserialize(contract, deserializer)
    klass = contract
    {
        parse_pipeline: ->(*) {
          ->(input, represented:, **) {
            if deserializer.is_a?(Symbol)
              klass.send(deserializer, input, represented, **input)
            elsif deserializer.is_a?(Class)
              # Todo
            else
              deserializer.call(input, represented, **input&.symbolize_keys)
            end
          }
        }
    }
  end

end
