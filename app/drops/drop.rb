class Drop < Liquid::Drop

  def initialize(object)
    @object = object
  end

  def object
    @object
  end

  alias_method :record, :object

end