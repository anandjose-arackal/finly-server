class Forms::Contracts::Transformers::Scope < Forms::Contracts::Transformers::Base

  register :scope

  def transform!
    return unless value

    if value[:enum]
      validate_enum
    elsif value[:choices]
      validate_choices
    elsif value[:auto_complete_route]
      validate_auto_complete
    elsif value[:resolver]
      validate_resolver
    end
    # validates << [name, presence: true]
  end

  def validate_enum
    name = self.name
    enum_klass = value[:enum]
    validate << -> do
      assigned_value = self.send(name)
      unless enum_klass.find_by(id: assigned_value).present?
        errors.add :base, "#{name.to_s.humanize} : invalid option selected"
      end
    end
  end

  def validate_choices
    name = self.name
    value = self.value[:choices]
    validate << -> do
      assigned_value = self.send(name)
      unless (value.select {|choice| choice[:value] == assigned_value}).present?
        errors.add :base, "#{name.to_s.humanize} : #{assigned_value} is an invalid option"
      end
    end
  end

  def validate_auto_complete
    name = self.name
    value = self.value
    validate << -> do
      assigned_value = self.send(name)
      route = value[:auto_complete_route]
      resolver = AutoComplete::Router.resolve(route)&.first&.klass
      result = resolver.(params: {q: {id_eq: assigned_value}}, current_user: RequestStoreUtil.current_user)
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
      resolver = value[:resolver]
      result = resolver.(params: {q: {id_eq: assigned_value}}, current_user: RequestStoreUtil.current_user)
      unless result.success? and result["model.records"].present?
        errors.add :base, "#{name.to_s.humanize} : invalid option selected"
      end
    end
  end



end