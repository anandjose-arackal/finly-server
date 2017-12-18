module Seedable
  extend ActiveSupport::Concern

  included do
    scope :with_id, -> (id) { where id: id }
    scope :with_name, -> (name) { where name: name }
  end

  class_methods do

    def values
      []
    end

    def ids_for(*keys)
      if keys.present? and keys.first.class.name == Array.name
        keys = keys.first
      end
      ids = []
      fetch_items.each do |key, value|
        ids << value if keys.include? key&.to_sym
      end
      ids
    end

    def id_for(key)
      return fetch_items[key]
    end

    def name_for(id)
      self.fetch_items.key(id)&.to_s
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

    # Checks if RequestStore contains the values. If not found, then loads RequestStore with the respective values
    def fetch_items
      values_map = RequestStoreUtil.seedable_values self.name
      if values_map.blank?
        values_map =  as_hash
        RequestStoreUtil.set_seedable_values self.name, values_map
      end
      values_map
    end

    # Generates a hash out of all the values in {name: id} format
    def as_hash
      values = {}
      self.all.each do |item|
        values[item.name.downcase] = item.id
      end
      values.with_indifferent_access
    end

  end

  def as_json(options={})
    {
        id: id,
        name: name
    }
  end

end