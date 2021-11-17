class Routers::Route
  attr_accessor :klass, :options

  def initialize(klass, options)
    self.klass = klass
    self.options = options
  end

  def dispatch(params, async=false)
    if async
      klass.call_async(params)
    else
      klass.(params)
    end
  end
end