module Observer::Master

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    unless defined?(observers)
      cattr_accessor :observers_list
      self.observers_list = []
    end

    unless defined?(observers_base_path)
      cattr_accessor :observers_base_path
    end

    # For development,
    def observers_path(path)
      self.observers_base_path = path
    end

    def add_observer(item)
      self.observers_list << item unless self.observers_list.include?(item)
    end

    def observers
      if self.observers_list.blank? and not Rails.env.production? and self.observers_base_path.present?
        Dir.glob("#{observers_base_path}/**/*.rb").each {|r| load r}
      end
      self.observers_list
    end

  end

end