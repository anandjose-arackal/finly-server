module Observer::Master

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def observers_master
      if OBSERVERS_MASTER[self.name].nil?
        OBSERVERS_MASTER[self.name] = {observers: [], observers_path: nil}
      end
      OBSERVERS_MASTER[self.name]
    end

    def observers_path(path = NoObject)
      unless path == NoObject
        observers_master[:observers_path] = path
      end
      observers_master[:observers_path]
    end

    def add_observer(item)
      list = observers_master[:observers]
      list << item unless list.include?(item)
    end

    def observers
      observers = observers_master[:observers]
      if observers.blank? and not Rails.env.production? and self.observers_path.present?
        Dir.glob("#{observers_path}/**/*.rb").each {|r| load r}
      end
      observers
    end

  end

end