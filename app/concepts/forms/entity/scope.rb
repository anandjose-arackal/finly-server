class Forms::Entity::Scope

  def self.scope_handlers
    @scope_handlers ||= {}.with_indifferent_access
  end

  def self.register(type, klass)
    scope_handlers[type] = klass
  end

  def self.handler(type)
    scope_handlers[type]
    # scope_handlers.find do |handler|
    #   handler.accept?(args)
    # end
  end

  def self.[](key)
    scope_handlers[key]
  end

  # def self.List(*args)
  #   {choices: args&.map { |m| m.slice(:value, :active) }}
  # end
  #
  # def self.AutoComplete(route, filters: {})
  #   {route: route.to_s, filters: filters}
  # end
  #
  # def self.Enum(klass, *keys)
  #   {enum: klass.to_s, keys: keys}
  # end
  #
  # def self.Resolver(klass, *keys, filters: {})
  #   {resolver: klass.to_s, keys: keys, filters: filters}
  # end
  #
  # def self.CheckBox()
  #   List({value: "true", active: true}, {value: "false", active: true})
  # end

  def self.choice_value(form_entity, user, choice)
    return nil unless (scope = form_entity.scope).present?

    if scope[:enum].present?
      return Object.const_get(scope[:enum]).all.find_by(name: choice)
    elsif scope[:resolver].present?
      resolver = Object.const_get(scope[:resolver])
      result = resolver.(params: {q: {name_eq: choice}}, current_user: user)
      return result['model.records'].first
    elsif scope[:route].present?
      route = scope[:route]
      resolver = AutoComplete::Router.resolve(route)&.first&.klass
      result = resolver.(params: {q: {name_eq: choice}}, current_user: user)
      return result['model.records']&.first
    elsif form_entity.choices.present?
      form_entity.choices.find_by(value: choice)
    end
  end

  def self.valid_choice?(form_entity, choice_id, user)
    return nil unless (scope = form_entity.scope).present?

    if scope[:enum].present?
      return Object.const_get(scope[:enum]).all.find_by(id: choice_id).present?
    elsif scope[:resolver].present?
      resolver = Object.const_get(scope[:resolver])
      result = resolver.(params: {q: {id_eq: choice_id}}, current_user: user)
      return result['model.records'].present?
    elsif scope[:route].present?
      route = scope[:route]
      resolver = AutoComplete::Router.resolve(route)&.first&.klass
      result = resolver.(params: {q: {id_eq: choice_id}}, current_user: user)
      return result['model.records'].present?
    elsif form_entity.choices.present?
      form_entity.choices.find_by(value: choice_id)&.id
    end
  end

  # def self.choices_for(form_entity)
  #   return [] unless (scope = form_entity.scope).present?
  #
  #   if scope[:enum].present?
  #     return Object.const_get(scope[:enum]).all.find_by(name: choice)&.id
  #   elsif scope[:resolver].present?
  #     resolver = Object.const_get(scope[:resolver])
  #     result = resolver.(params: {q: {name_eq: choice}}, current_user: user_scope)
  #     return result['model.records'].first&.id
  #   elsif scope[:route].present?
  #     route = scope[:route]
  #     resolver = AutoComplete::Router.resolve(route)&.first&.klass
  #     result = resolver.(params: {q: {name_eq: choice}}, current_user: user_scope)
  #     return result['model.records']&.first&.id
  #   elsif scope[:choices].present?
  #     form_entity.choices.find_by(value: choice)&.id
  #   end
  # end

end