class Choices::Builders::Resolver < Choices::Builders::Base

  register! :resolver

  def self.call(klass, *keys)
    self.new({resolver: klass.to_s, keys: keys, filters: filters})
  end

  def klass
    Object.const_get(config[:klass].to_s)
  end

  def keys
    config[:keys]
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

end