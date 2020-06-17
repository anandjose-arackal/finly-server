class Dashboard::Row

  attr_accessor :type, :options

  def initialize(type, options = {}, &block)
    self.type = type
    self.options = options
    instance_exec &block
  end

  def tiles
    @tiles ||= []
  end

  def tile(title, options = {})
    tiles << Dashboard::Tile.new(title, self.options.merge(options))
  end



end