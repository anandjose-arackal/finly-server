module Seedable
  extend ActiveSupport::Concern

  included do
    scope :with_name, -> { where name: self.name }
  end

  class_methods do
    def values
      []
    end

    def id_for(name)
      items = self.with_name(name)
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