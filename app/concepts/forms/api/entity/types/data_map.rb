class Forms::API::Entity::Types::DataMap < Forms::API::Entity::Base

  register :data_map

  option :min_items

  contract do
    required(:options) do
      hash do
        optional(:min_items).value(:int?)
      end
    end
  end

end