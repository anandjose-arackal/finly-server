module Seedable
  extend ActiveSupport::Concern

  included do
    scope :with_name, -> (name) { where name: name }
  end

  class_methods do
    def values
      []
    end

    def ids_for(keys)
      items = self.with_name(keys)
      if items.present?
        return items.pluck(:id)
      end
      return nil
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
      # todo handle destroying data if it should not exist in database
    end
    alias_method :sync_data, :seed_data

  end

end