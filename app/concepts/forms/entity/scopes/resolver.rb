class Forms::Entity::Scopes::Resolver < Forms::Entity::Scopes::Base

  register! :resolver

  # def self.accept?(args)
  #   args[:resolver].present?
  # end

  def klass
    Object.const_get(scope[:klass].to_s)
  end

  def keys
    scope[:keys]
  end

  def find(choice, user: nil)
    resolver = Object.const_get(klass.to_s)
    result = resolver.(params: {q: {name_eq: choice}}, current_user: user)
    result['model.records'].first
  end

  def valid?(choice, user: nil)
    find(choice).present?
  end

  def self.scope(klass, *keys)
    {type: :resolver, resolver: klass.to_s, keys: keys, filters: filters}
  end

end