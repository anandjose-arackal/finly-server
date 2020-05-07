class Forms::API::Entity::Types::DropDown < Forms::API::Entity::Base
  register :dropdown
  hint 'Select value'

  operators :eq_any, :not_eq_all, :not_null, :null

  consumes_choices!

  option :min_items
  option :min_items

  contract do
    required(:options) do
      hash do
        optional(:min_items).value(:int?)
        optional(:min_items).value(:int?)
      end
    end
  end
end