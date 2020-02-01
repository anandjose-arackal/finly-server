class Forms::Entity::Scopes::Enum < Forms::Entity::Scopes::Base

  register! :enum

  def klass
    Object.const_get(scope[:enum].to_s)
  end

  def keys
    scope[:keys]
  end

  def find(choice, user: nil)
    klass.where(name: choice).or(klass.where(id: choice)).first
  end

  def valid?(choice, user: nil)
    find(choice).present?
  end

  def self.scope(klass, *keys)
    {type: :enum, enum: klass.to_s, keys: keys}
  end

end