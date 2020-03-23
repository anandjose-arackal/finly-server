class Forms::API::Entity::Types::LargeText < Forms::API::Entity::Base
  register :large_text
  hint "Enter value"

  option :char_limit, default: 65535 #{numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 255, only_integer: true}}

  operators :eq_any, :not_eq_all, :cont_any, :not_cont_all, :blank, :present

  contract do
    required(:char_limit).value(:int?, lteq?: 65535)
  end
end