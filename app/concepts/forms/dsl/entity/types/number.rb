class Forms::DSL::Entity::Types::Number < Forms::DSL::Entity::Base
  register :number
  hint 'Enter value'

  option :max_value
  option :min_value
  option :decimal, default: false

  contract do
    optional(:min_value).value(:int?)
    optional(:max_value).value(:int?)
    optional(:decimal).value(:bool?)
  end
end