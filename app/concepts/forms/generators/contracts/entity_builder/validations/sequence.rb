class Forms::Generators::Contracts::EntityBuilder::Validations::Sequence < Forms::Generators::Contracts::EntityBuilder::Validations::Base

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