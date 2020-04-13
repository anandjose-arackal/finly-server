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

  def klass
    ::Resolver::Router.resolve(route)&.first&.klass
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
    result = klass.(params: params, current_user: user)
    result['model.records']
  end

  def build(params: {}, user: {})
    params = params.with_indifferent_access.deep_merge(choice_params.with_indifferent_access)
    if klass.nil?
      debugger
    end
    result = klass.(params: params, current_user: user).as_json

    {
        partial: false, choices: result
    }
  end

end