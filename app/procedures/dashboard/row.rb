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

  def tile(options = {})
    @tiles << Dashboard::Tile.new(self.options.merge(options))
  end

  def build(card)
    {
        type: type,
        data: tiles.map { |tile| tile.build(card) }
    }
  end

end