module Initializable

  def pre_initialize(params = {})

  end

  def initialize(params = {})
    pre_initialize params
    params.each do |key, value|
      setter = "#{key}="
      send(setter, value) if respond_to?(setter.to_sym, false)
    end
    post_initialize params
  end

  def post_initialize(params = {})

  end

end