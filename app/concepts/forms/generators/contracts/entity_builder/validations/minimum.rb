class Forms::Generators::Contracts::EntityBuilder::Validations::Minimum < Forms::Generators::Contracts::EntityBuilder::Validations::Base

  register :minimum

  def transform!
    return unless value

    validates << [name, {length: {minimum: 1}}]
  end


end