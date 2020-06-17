class IndexSegment::SystemViews::Registry

  def self.registry
    @registry ||= {}.with_indifferent_access
  end

  def self.register(screen, klass)
    registry[screen] ||= []
    registry[screen] << klass unless registry[screen].include?(klass)
  end

  def self.system_views(screen)
    registry[screen] ||= []
  end

end