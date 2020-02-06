class Forms::DSL::Entity::Scopes::Enum < Forms::DSL::Entity::Scopes::Base

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

  def self.scope(klass, *keys)
    {type: :enum, enum: klass.to_s, keys: keys}
  end

end