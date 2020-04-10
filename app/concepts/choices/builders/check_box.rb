class Choices::Builders::CheckBox < Choices::Builders::Base

  register! :checkbox

  def self.call
    self.new({choices: [{name: "true", active: true}, {name: "false", active: true}]})
  end

  def choices(params: {}, user: nil)
    # Todo Generalize!
    form_entity.form_entity_choices
  end

  def choices_json(params: {}, user: nil)
    choices(params: {}, user: nil).as_json
  end

  def find_by_id(id, params: {}, user: nil)
    choices(params: params, user: user).find_by("name = #{id} OR id = #{id}")
  end

  def find_by_name(name, params: {}, user: nil)
    choices(params: params, user: user).find_by("name = #{name} OR id = #{name}")
  end

  def valid?(id: nil, name: nil, user: nil)
    return true if [true, "true", "false", false].include?(id)
    return true if [true, "true", "false", false].include?(name)
    return true if find_by_id(choice, user: user).present?
    return true if find_by_name(choice, user: user).present?

    false
  end

  def build(params: {}, user: {})
    {partial: false, choices: choices(params: params, user: user).as_json}
  end

end