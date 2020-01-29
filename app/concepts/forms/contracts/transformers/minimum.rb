class Forms::Contracts::Transformers::Minimum < Forms::Contracts::Transformers::Base

  register :minimum

  def transform!
    return unless value

    validates << [name, {length: {minimum: 1}}]
  end


end