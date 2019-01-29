module Observer::Master

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    unless defined?(observers)
      cattr_accessor :observers
      self.observers = []
    end

    def add_observer(item)
      self.observers << item unless self.observers.include?(item)
    end

  end

end