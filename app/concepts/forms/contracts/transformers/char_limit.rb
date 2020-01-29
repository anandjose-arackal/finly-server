class Forms::Contracts::Transformers::CharLimit < Forms::Contracts::Transformers::Base

  register :char_limit

  def transform!
    return unless value

    validates << [name, length: {maximum: value}]
  end


end