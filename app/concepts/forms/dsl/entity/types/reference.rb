class Forms::DSL::Entity::Types::Reference < Forms::DSL::Entity::Base
  register :reference

  option :class_name

  contract do
    required(:class_name).filled
  end
end