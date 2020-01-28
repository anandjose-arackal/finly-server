class Forms::Contracts::Transformers::Required < Forms::Contracts::Transformers::Base

  register :required

  def initialize(name, value)
    return unless value

    validates << [name, presence: true]
  end


end