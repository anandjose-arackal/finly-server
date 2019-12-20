class Transactions::Contract < Reform::Form
  def add_schema_errors(errors_list)
    errors_list.to_h.each do |attr, err_list|
      # if err_list.is_a?(Hash)
      #   add_schema_errors(err_list)
      # elsif err_list.respond_to?(:each)
      #   err_list.each do |e|
      #     errors.add attr, e
      #   end
      # else
      #   errors.add attr, err_list
      # end
      errors.add attr, err_list
    end
  end

  def self.Deserialize(deserializer)
    klass = self
    {
        parse_pipeline: ->(*) {
          ->(input, represented:, **) {
            if deserializer.is_a?(Symbol)
              klass.send(deserializer, input, represented, **input)
            elsif deserializer.is_a?(Class)
              # Todo
            else
              deserializer.call(input, represented, **input)
            end
          }
        }
    }
  end

end