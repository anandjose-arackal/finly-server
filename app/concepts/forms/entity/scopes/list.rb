class Forms::Entity::Scopes::List < Forms::Entity::Scopes::Base

  register! :list

  # def self.accept?(args)
  #   args[:choices].present?
  # end

  def find_by_id(choice, user: nil)
    form_entity.choices.find_by(uuid: choice)
  end

  def find_by_name(choice, user: nil)
    form_entity.choices.find_by(value: choice)
  end

  def self.scope(*args)
    {type: :list, choices: args&.map { |m| m.slice(:value, :active) }}
  end

end