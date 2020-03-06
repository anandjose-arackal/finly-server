class Forms::ChoiceProviders::Enum < Forms::ChoiceProviders::Base

  register! :enum

  def self.config(klass, id: :id, name: :name)
    {type: :enum, enum: klass.to_s, id: id, name: name}
  end

  def klass
    Object.const_get(config[:enum].to_s)
  end

  def id
    config[:id]
  end

  def name
    config[:name]
  end

  def choices(params: {}, user: nil)
    klass.all
  end

  def choices_json(params: {}, user: nil)
    choices(params: {}, user: nil).as_json
  end

  def find_by_id(id, params: {}, user: nil)
    choices(params: params, user: user).where(id: id).first
  end

  def find_by_name(name, params: {}, user: nil)
    choices(params: params, user: user).where(name: name).first
  end

  def as_json(options={})
    list = []
    klass.all.each do |item|
      list << {
          id: item.send(id),
          name: item.send(name),
      }
    end

    {
        partial: false,
        choices: list
    }
  end

end