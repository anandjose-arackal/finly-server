class Forms::DSL::Entity::Types::LargeText < Forms::DSL::Entity::Base
  register :large_text
  hint "Enter value"

  option :char_limit, default: 65535 #{numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 255, only_integer: true}}

  contract do
    required(:char_limit).value(:int?, lteq?: 65535)
  end
end