class Transactions::Contracts::PreProcessors::Value < Transactions::Contracts::PreProcessors::Base

  register!

  def run!
    return false unless options[:value].present?
    return false if options[:deserializer].present?
    options[:deserializer] = deserialize(name, options[:value])
    true
  end

  def deserialize(name, value)
    {
        parse_pipeline: ->(*) {
          ->(input, represented:, **) {
            represented.send("#{name}=", value)
          }
        }
    }
  end

end
