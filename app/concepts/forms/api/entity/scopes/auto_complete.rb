class Forms::API::Entity::Scopes::AutoComplete < Forms::API::Entity::Scopes::Base

  register! :auto_complete

  def route
    scope[:route]
  end

  def filters
    scope[:filters]
  end

  def klass
    ::AutoComplete::Router.resolve(route)&.first&.klass
  end

  def find_by_id(choice, user: nil)
    result = klass.(params: {q: {id_eq: choice}}, current_user: user)
    result['model.records']&.first
  end

  def find_by_name(choice, user: nil)
    result = klass.(params: {q: {name_eq: choice}}, current_user: user)
    result['model.records']&.first
  end

  def self.scope(route, filters)
    {type: :auto_complete, route: route.to_s, filters: filters}
  end

  def as_json(options={})
    {
        type: :auto_complete, route: route
    }
  end
end