class Forms::API::Entity::Scopes::List < Forms::API::Entity::Scopes::Base

  register! :list

  # def self.accept?(args)
  #   args[:choices].present?
  # end

  def choices(params: {}, user: nil)
    form_entity.choices
  end

  def find_by_id(id, params: {}, user: nil)
    choices(params: params, user: user).find_by(uuid: id)
  end

  def find_by_name(name, params: {}, user: nil)
    choices(params: params, user: user).find_by(name: name)
  end

  def self.scope(*args)
    {type: :list, choices: args&.map {|m| m.slice(:name, :active)}}
  end

  def as_json(params: {}, user: nil)
    # Todo: Allow partial list based on the size of the choices
    {partial: false, choices: choices(params: params, user: user).as_json}
  end

end