class Forms::Contracts::EntityBuilder::Validations::CharLimit < Forms::Contracts::EntityBuilder::Validations::Base

  register :char_limit

  def transform!
    return unless value

    validates << [name, length: {maximum: value}]
  end


end