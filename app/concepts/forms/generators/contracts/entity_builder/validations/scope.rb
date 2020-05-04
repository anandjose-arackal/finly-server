class Forms::Generators::Contracts::EntityBuilder::Validations::Scope < Forms::Generators::Contracts::EntityBuilder::Validations::Base

  register :scope

  def transform!
    return unless value

    name = self.name
    value = self.value
    validate << -> do
      assigned_value = self.send(name)
      unless value.valid?(id: assigned_value, user: RequestStore[:owner_scope])
        errors.add :base, "#{name.to_s.humanize} : invalid option selected"
      end
    end
  end

end