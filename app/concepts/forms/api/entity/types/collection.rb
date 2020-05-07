class Forms::API::Entity::Types::Collection < Forms::API::Entity::Base

  register :collection

  option :min_items

  contract do
    required(:options) do
      hash do
        optional(:min_items).value(:int?)
      end
    end
  end

end