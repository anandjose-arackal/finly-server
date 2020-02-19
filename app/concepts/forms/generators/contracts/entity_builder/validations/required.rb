class Forms::Generators::Contracts::EntityBuilder::Validations::Required < Forms::Generators::Contracts::EntityBuilder::Validations::Base

  register :required

  def transform!
    return unless value

    validates << [name, presence: true]
  end


end