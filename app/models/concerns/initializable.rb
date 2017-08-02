module Initializable

  def before_initialize(params = {})

  end

  def initialize(params = {})
    before_initialize params
    params.each do |key, value|
      setter = "#{key}="
      send(setter, value) if respond_to?(setter.to_sym, false)
    end
    after_initialize params
  end

  def after_initialize(params = {})

  end

end