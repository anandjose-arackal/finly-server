class Forms::Generators::Contracts::EntityBuilder::Validations::DefaultValue < Forms::Generators::Contracts::EntityBuilder::Validations::Base

  register :default_value

  def transform!
    return unless value

    name = self.name
    value = self.value
    setters << -> do
      send("#{name}=", value) unless send(name).present?
    end
  end


end