class Rules::Operator
  attr_accessor :entity_path

  def initialize(entity_path)
    self.entity_path = entity_path
  end

  Rules::Constants::PREDICATES.each do |predicate|
    define_method predicate do |*values|
      if Rules::Constants::NON_VALUE_PREDICATES.include?(predicate)
        values = [
            {
                value: 1
            }
        ]
      else
        values = values.map { |val|
          # if values is a hash, val will be an array of [key, value]
          val = val[1] if val.is_a?(Array)

          val.slice(:value, :entity, :formula)
        }
      end
      Rules::Rule.new(
          predicate,
          attribute: {name: entity_path},
          value: values
      )
    end
  end
end