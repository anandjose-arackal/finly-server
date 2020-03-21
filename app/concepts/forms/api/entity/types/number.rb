class Forms::API::Entity::Types::Number < Forms::API::Entity::Base
  register :number
  hint 'Enter value'

  option :max_value
  option :min_value
  option :decimal, default: false

  operators :eq_any, :gteq, :lteq, :blank

  contract do
    optional(:min_value).value(:int?)
    optional(:max_value).value(:int?)
    optional(:decimal).value(:bool?)
  end
end