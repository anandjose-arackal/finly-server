class Menu::Registry

  def self.registry
    @registry ||= []
  end

  def self.register(klass)
    registry << klass
  end

end