class Forms::API::Entity::Scopes::Enum < Forms::API::Entity::Scopes::Base

  register! :enum

  def klass
    Object.const_get(scope[:enum].to_s)
  end

  def value
    scope[:value]
  end

  def name
    scope[:name]
  end

  def find_by_id(choice, user: nil)
    klass.where(id: choice).first
  end

  def find_by_name(choice, user: nil)
    klass.where(name: choice).first
  end

  def self.scope(klass, value: :id, name: :name)
    {type: :enum, enum: klass.to_s, value: value, name: name}
  end

  def choices
    list = []
    klass.all.each do |item|
      list << {
          value: item.send(value),
          name: item.send(name),
      }
    end
    list
  end

  def as_json(options={})
    {
        type: :enum,
        choices: choices
    }
  end

end