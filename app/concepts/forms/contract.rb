class Forms::Contract < Reform::Form

  module Forms::Contract::ModelHelper
    extend ActiveSupport::Concern

    included do
      include DynamicAttributes

      class_attr :owner_scope
    end

  end

  # Overriding validate to capture the owner_scope as it was very difficult to
  # find the root contract from nested contracts. RequestStore[:owner_scope] is used for validating
  # the user when the resolver / auto-complete is set
  def validate(input)
    if RequestStore[:owner_scope].nil?
      scope = model.class.owner_scope
      RequestStore[:owner_scope] = send(scope) || input[scope]
    end
    result = super(input)
    RequestStore[:owner_scope] = nil
    result
  end

end