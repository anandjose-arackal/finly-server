class Routers::Route
  attr_accessor :klass, :options

  def initialize(klass, options)
    self.klass = klass
    self.options = options
  end

  def dispatch(params)
    klass.(params)
  end
end