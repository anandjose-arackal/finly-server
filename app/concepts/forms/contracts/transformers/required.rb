class Forms::Contracts::Transformers::Required < Forms::Contracts::Transformers::Base

  register :required

  def transform!
    return unless value

    validates << [name, presence: true]
  end


end