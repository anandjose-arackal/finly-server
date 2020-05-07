class Forms::API::Entity::Types::Reference < Forms::API::Entity::Base
  register :reference

  option :class_name

  operators :eq_any, :blank, :present

  contract do
    required(:options) do
      hash do
        required(:class_name).filled
      end
    end
  end
end