class Forms::Entity::Types::Reference < Forms::Entity::Base
  register :reference

  option :class_name

  contract do
    required(:class_name).filled
  end
end