class Choices::Builders::Resolver < Choices::Builders::Base

  register! :resolver

  def self.call(route, choice_params = {})
    self.new({route: route.to_s, choice_params: choice_params})
  end

  def route
    config[:route]
  end

  def choice_params
    config[:choice_params]
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
    params = params.with_indifferent_access.deep_merge(choice_params.with_indifferent_access)
    ::Resolver::Router.dispatch(route, params: params, current_user: user)
  end

  def build(params: {}, user: {})
    params = params.with_indifferent_access.deep_merge(choice_params.with_indifferent_access)
    result = ::Resolver::Router.dispatch(route, params: params, current_user: user)
    Choices::Provider.new(provider: self, partial: false, data: result)
  end

end