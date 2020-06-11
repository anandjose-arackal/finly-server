class Dashboard::Row
  include DynamicAttributes

  attr_accessor :options, :block

  def initialize(options, &block)

  end

  def tiles
    @tiles ||= []
  end

  def tile(options, &block)

  end

end