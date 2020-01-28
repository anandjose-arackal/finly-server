class Forms::Contracts::Transformers::MaxValue < Forms::Contracts::Transformers::Base

  register :min_value

  def initialize(name, value)
    return unless value

    validates << [name, numericality: { greater_than_or_equal_to: value}]
  end


end