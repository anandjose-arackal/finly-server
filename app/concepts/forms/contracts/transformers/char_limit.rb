class Forms::Contracts::Transformers::CharLimit < Forms::Contracts::Transformers::Base

  register :char_limit

  def initialize(name, value)
    return unless value

    validates << [name, length: {maximum: value}]
  end


end