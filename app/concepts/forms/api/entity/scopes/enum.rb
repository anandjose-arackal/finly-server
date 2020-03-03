class Forms::API::Entity::Scopes::Enum < Forms::API::Entity::Scopes::Base

  register! :enum

  def klass
    Object.const_get(scope[:enum].to_s)
  end

  def keys
    scope[:keys]
  end

  def find_by_id(choice, user: nil)
    klass.where(id: choice).first
  end

  def find_by_name(choice, user: nil)
    klass.where(name: choice).first
  end

  def self.scope(klass, id: :id, name: :name)
    {type: :enum, enum: klass.to_s, id: id, name: name}
  end

  def choices
    list = []
    klass.all.each do |item|
      map = {}
      map[:id] = keys[:id]
      map[:name] = keys[:name]
      list << map
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