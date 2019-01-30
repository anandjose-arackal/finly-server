module Observer::Master

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def observers_master
      if OBSERVERS_MASTER[self.name].nil?
        OBSERVERS_MASTER[self.name] = {observers_list: [], observers_base_path: nil}
      end
      OBSERVERS_MASTER[self.name]
    end

    def observers_list
      observers_master[:observers_list]
    end

    def observers_base_path
      observers_master[:observers_base_path]
    end

    # For development,
    def observers_path(path)
      observers_master[:observers_base_path] = path
    end

    def add_observer(item)
      list = observers_list
      list << item unless list.include?(item)
    end

    def observers
      if self.observers_list.blank? and not Rails.env.production? and self.observers_base_path.present?
        Dir.glob("#{observers_base_path}/**/*.rb").each {|r| load r}
      end
      self.observers_list
    end

  end

end