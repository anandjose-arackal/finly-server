class Forms::API::Entity::Types::Table < Forms::API::Entity::Base

  register :table

  option :min_items

  contract do
    optional(:min_items).value(:int?)
  end

end