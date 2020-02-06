class Forms::Contracts::EntityBuilder::Validations::MaxValue < Forms::Contracts::EntityBuilder::Validations::Base

  register :max_value

  def transform!
    return unless value

    validates << [name, numericality: { less_than_or_equal_to: value}]
  end


end