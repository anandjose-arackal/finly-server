class Forms::DSL::Entity::Scopes::CheckBox < Forms::DSL::Entity::Scopes::Base

  register! :checkbox

  # def self.accept?(args)
  #   args[:checkbox]
  # end

  def find_by_id(choice, user: nil)
      form_entity.choices.find_by("value = #{choice} OR id = #{choice}")
  end

  def find_by_name(choice, user: nil)
    form_entity.choices.find_by("value = #{choice} OR id = #{choice}")
  end

  def valid?(id: nil, name: nil, user: nil)
    return true if [true, "true", "false", false].include?(id)
    return true if [true, "true", "false", false].include?(name)
    return true if find_by_id(choice, user: user).present?
    return true if find_by_name(choice, user: user).present?

    false
  end

  def self.scope
    {type: :checkbox, choices: [{value: "true", active: true}, {value: "false", active: true}]}
  end

end