class Forms::API::Entity::Scopes::AutoComplete < Forms::API::Entity::Scopes::Base

  register! :auto_complete

  def route
    scope[:route]
  end

  def scope_params
    scope[:scope_params]
  end

  def klass
    ::AutoComplete::Router.resolve(route)&.first&.klass
  end

  def find_by_id(id, params: {}, user: nil)
    params.deep_merge!({q: {id_eq: id}})
    choices(params: params, user: user)&.first
  end

  def find_by_name(name, params: {}, user: nil)
    params.deep_merge!({q: {name_eq: name}})
    choices(params: params, user: user)&.first
  end

  def choices(params: {}, user: nil)
    params = params.with_indifferent_access.deep_merge(scope_params.with_indifferent_access)
    result = klass.(params: params, current_user: user)
    result['model.records']
  end

  def self.scope(route, scope_params)
    {type: :auto_complete, route: route.to_s, scope_params: scope_params}
  end

  def as_json(params: {}, user: nil)
    params = params.with_indifferent_access.deep_merge(scope_params.with_indifferent_access)
    result = klass.(params: params, current_user: user)

    partial = result['model.records.json'].size == result["per_page"]
    {
        partial: partial, choices: result['model.records.json']
    }
  end
end