class Forms::Entity::Scopes::AutoComplete < Forms::Entity::Scopes::Base

  register! :auto_complete

  def route
    scope[:route]
  end

  def filters
    scope[:filters]
  end

  def find(choice, user: nil)
    resolver = ::AutoComplete::Router.resolve(route)&.first&.klass
    result = resolver.(params: {q: {name_eq: choice}}, current_user: user)
    result['model.records']&.first
  end

  def valid?(choice, user: nil)
    find(choice).present?
  end

  def self.scope(route, filters)
    {type: :auto_complete, route: route.to_s, filters: filters}
  end
end