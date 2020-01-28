class Forms::Contracts::Transformers::Minimum < Forms::Contracts::Transformers::Base

  register :minimum

  def initialize(name, value)
    return unless value

    validates << [name, {length: {minimum: 1}}]
  end


end