class Forms::API::Entity::Types::List < Forms::API::Entity::Base

  register :list

  option :min_items

  contract do
    required(:options) do
      hash do
        optional(:min_items).value(:int?)
      end
    end
  end

end