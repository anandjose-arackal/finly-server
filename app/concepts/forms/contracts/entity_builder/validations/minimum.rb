class Forms::Contracts::EntityBuilder::Validations::Minimum < Forms::Contracts::EntityBuilder::Validations::Base

  register :minimum

  def transform!
    return unless value

    validates << [name, {length: {minimum: 1}}]
  end


end