module Seedable
  extend ActiveSupport::Concern

  included do
    scope :with_name, -> (name) { where name: name }
  end

  class_methods do
    def values
      []
    end

    def id_for(key)
      items = self.with_name(key)
      if items.present?
        return items.first.id
      end
      return nil
    end

    def seed_data
      c = self.count
      self.values.each do |name|
        if c == 0 or self.with_name(name).blank?
          self.create name: name
        end
      end
    end
  end

end