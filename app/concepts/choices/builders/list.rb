class Choices::Builders::List < Choices::Builders::Base

  register! :list

  def self.call(*args)
    self.new({choices: args&.map {|m| m.slice(:name, :active)}})
  end

  def choices(params: {}, user: nil, form_entity: nil)
    if form_entity.present?
      # Todo Generalize!
      form_entity.form_entity_choices
    else
      config[:choices]
    end
  end

  def find_by_id(id, params: {}, user: nil)
    choices(params: params, user: user).find_by(uuid: id)
  end

  def find_by_name(name, params: {}, user: nil)
    choices(params: params, user: user).find_by(name: name)
  end

  def build(params: {}, user: nil)
    # Todo: Allow partial list based on the size of the choices
    {partial: false, choices: choices(params: params, user: user).as_json}
  end

end