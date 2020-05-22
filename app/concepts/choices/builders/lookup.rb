class Choices::Builders::Lookup < Choices::Builders::Base

  register! :lookup

  def self.call(route, choice_params = {})
    self.new({route: route.to_s, choice_params: choice_params})
  end

  def route
    config[:route]
  end

  def choice_params
    config[:choice_params]
  end

  def klass
    ::Lookup::Router.resolve(route)&.first&.klass
  end

  def find_by_id(id, params: {}, user: nil)
    return finder_cache[:id][id] if finder_cache[:id][id].present?

    params.deep_merge!({q: {id_eq: id}})
    choices(params: params, user: user)&.first
  end

  def find_by_name(name, params: {}, user: nil)
    return finder_cache[:id][name] if finder_cache[:id][name].present?

    params.deep_merge!({q: {name_eq: name}})
    choices(params: params, user: user)&.first
  end

  def choices(params: {}, user: nil)
    params = params.with_indifferent_access.deep_merge(choice_params.with_indifferent_access)
    result = klass.(params: params, current_user: user)
    result['model.records']
  end

  def build(params: {}, user: {})
    params = params.with_indifferent_access.deep_merge(choice_params.with_indifferent_access)
    result = klass.(params: params, current_user: user)

    partial = result['model.records.json'].size == result['per_page']
    Choices::Provider.new(data: result['model.records'], partial: partial, json: result['model.records.json'])
  end
end