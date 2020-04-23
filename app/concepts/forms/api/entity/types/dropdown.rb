class Forms::API::Entity::Types::DropDown < Forms::API::Entity::Base
  register :dropdown
  hint 'Select value'

  operators :eq_any, :not_eq_all, :null, :null_not

  consumes_choices!

  option :min_choices
  option :max_choices

  contract do
    optional(:min_choices).value(:int?)
    optional(:max_choices).value(:int?)
  end
end