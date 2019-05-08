module Seedable
  extend ActiveSupport::Concern

  included do
    scope :with_id, -> (id) {where id: id}
    scope :with_name, -> (name) {where name: name}
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
      keys.each do |key|
        ids << id_for(key)
      end
      ids.reject {|item| item.blank?}
    end

    def id_for(key)
      val = SEEDABLE_CACHE&.dig(name, key)
      if val.nil? and (self.values.include?(key&.to_sym) || self.values.include?(key&.to_s))
        seed_data
      end
      SEEDABLE_CACHE&.dig(name, key)
    end

    def name_for(id)
      SEEDABLE_CACHE[name]&.key(id)&.to_s
    end

    def seed_data
      c = self.count
      self.values.each do |name|
        if c == 0 or self.with_name(name).blank?
          self.create name: name
        end
      end
      refresh_cache
      # todo handle destroying data if it should not exist in database
    end

    alias_method :sync_data, :seed_data

    def refresh_cache
      SEEDABLE_CACHE[name] = {}.with_indifferent_access
      as_hash&.each do |key, val|
        SEEDABLE_CACHE[name][key] = val
      end
    end

    # Generates a hash out of all the values in {name: id} format
    def as_hash
      values = HashInsensitive.new

      return values unless ApplicationRecord.connection.table_exists? self.table_name
      self.all.each do |item|
        values[item.name] = item.id
      end

      values.with_indifferent_access
    end

  end

  def as_json(options = {})
    {
        id: id,
        name: name
    }
  end

  # Load all values of all variables in SimpleConfig
  def self.refresh_all_caches
    if Rails.env.development?
      Rails.application.eager_load!
    end
    seedable_classes = ObjectSpace.each_object(Class).select {|c| c.included_modules.include?(Seedable)}
    values = {}
    seedable_classes.each do |seedable_class|
      seedable_class.refresh_cache
    end
  end

end