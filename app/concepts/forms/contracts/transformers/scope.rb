class Forms::Contracts::Transformers::Scope < Forms::Contracts::Transformers::Base

  register :scope

  # def transform!
  #   return unless value
  #
  #   name = self.name
  #   entity = self.entity
  #
  #   validate << -> do
  #     assigned_value = self.send(name)
  #     unless Forms::Entity::Scope.valid_choice?(entity, assigned_value, user_scope)
  #       errors.add :base, "#{name.to_s.humanize} : invalid option selected"
  #     end
  #   end
  # end

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

    # if value[:enum]
    #   validate_enum
    # elsif value[:choices]
    #   validate_choices
    # elsif value[:route]
    #   validate_auto_complete
    # elsif value[:resolver]
    #   validate_resolver
    # end
    # validates << [name, presence: true]
  end

  def validate_enum
    name = self.name
    enum_klass = value[:enum]
    validate << -> do
      assigned_value = self.send(name)
      unless Object.const_get(enum_klass).find_by(id: assigned_value).present?
        errors.add :base, "#{name.to_s.humanize} : invalid option selected"
      end
    end
  end

  def validate_choices
    name = self.name
    value = entity.choices #self.value[:choices]
    validate << -> do
      assigned_value = self.send(name)
      unless (value.select {|choice| choice.id&.to_s == assigned_value&.to_s or choice.value&.to_s == assigned_value&.to_s}).present?
        errors.add :base, "#{name.to_s.humanize} : #{assigned_value} is an invalid option"
      end
    end
  end

  def validate_auto_complete
    name = self.name
    value = self.value
    validate << -> do
      assigned_value = self.send(name)
      route = value[:route]
      resolver = AutoComplete::Router.resolve(route)&.first&.klass
      result = resolver.(params: {q: {id_eq: assigned_value}}, current_user: user_scope)
      unless result.success? and result["model.records"].present?
        errors.add :base, "#{name.to_s.humanize} : invalid option selected"
      end
    end
  end

  def validate_resolver
    name = self.name
    value = self.value
    validate << -> do
      assigned_value = self.send(name)
      resolver = Object.const_get(value[:resolver])
      result = resolver.(params: {q: {id_eq: assigned_value}}, current_user: user_scope)
      unless result.success? and result["model.records"].present?
        errors.add :base, "#{name.to_s.humanize} : invalid option selected"
      end
    end
  end

end