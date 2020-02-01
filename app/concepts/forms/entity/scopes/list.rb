class Forms::Entity::Scopes::List < Forms::Entity::Scopes::Base

  register! :list

  # def self.accept?(args)
  #   args[:choices].present?
  # end

  def find(choice, user: nil)
    if form_entity.present?
      form_entity.choices.find_by(value: choice)
    else
      # Todo maybe handle it directly from the list of choices?
    end
  end

  def valid?(choice, user: nil)
    find(choice, user: user).present?
  end

  def self.scope(*args)
    {type: :list, choices: args&.map { |m| m.slice(:value, :active) }}
  end

end