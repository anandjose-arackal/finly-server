class Forms::Entity::Scopes::CheckBox < Forms::Entity::Scopes::Base

  register! :checkbox

  # def self.accept?(args)
  #   args[:checkbox]
  # end

  def find(choice, user: nil)
    if form_entity.present?
      form_entity.choices.find_by("value = #{choice} OR id = #{choice}")
    else
      # Todo maybe handle it directly from the list of choices?
    end
  end

  def valid?(choice, user: nil)
    [true, "true", "false", false].include?(choice) or find(choice, user: user).present?
  end

  def self.scope
    {type: :checkbox, choices: [{value: "true", active: true}, {value: "false", active: true}]}
  end

end