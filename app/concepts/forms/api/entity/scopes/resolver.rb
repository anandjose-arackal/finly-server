class Forms::API::Entity::Scopes::Resolver < Forms::API::Entity::Scopes::Base

  register! :resolver

  def klass
    Object.const_get(scope[:klass].to_s)
  end

  def keys
    scope[:keys]
  end

  def choices(params: {}, user: nil)
    params = params.with_indifferent_access.deep_merge(scope_params.with_indifferent_access)
    result = klass.(params: params, current_user: user)
    result['model.records']
  end

  def find_by_id(id, params: {}, user: nil)
    params.deep_merge!({q: {id_eq: id}})
    choices(params: params, user: user)&.first
  end

  def find_by_name(name, params: {}, user: nil)
    params.deep_merge!({q: {name_eq: name}})
    choices(params: params, user: user)&.first
  end

  def self.scope(klass, *keys)
    {type: :resolver, resolver: klass.to_s, keys: keys, filters: filters}
  end

end