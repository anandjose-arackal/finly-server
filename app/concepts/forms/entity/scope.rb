class Forms::Entity::Scope

  def self.List(*args)
    {choices: args&.map { |m| m.slice(:value, :name, :active) }}
  end

  def self.AutoComplete(route, filters: {})
    {auto_complete_route: route.to_s, filters: filters}
  end

  def self.Enum(klass, *keys)
    {enum: klass.to_s, keys: keys}
  end

  def self.Resolver(klass, *keys, filters: {})
    {resolver: klass.to_s, keys: keys, filters: filters}
  end

end