class Forms::Contracts::Transformers::CharLimit < Forms::Contracts::Transformers::Base

  register :sequence

  def transform!
    return unless value

    name = self.name
    validate << -> do
      # Todo generation of sequence
      # send("#{name}=", next_id)
    end
  end


end