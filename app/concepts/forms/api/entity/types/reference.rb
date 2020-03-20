class Forms::API::Entity::Types::Reference < Forms::API::Entity::Base
  register :reference

  option :class_name

  contract do
    required(:class_name).filled
  end
end