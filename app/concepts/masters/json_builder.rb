# Masters::JsonBuilder is built for fixing N+1 query problems that could arise with dynamically masters.
class Masters::JsonBuilder

  def self.call(master_schema, record)
    new(master_schema).build(record)
  end

  attr_accessor :master_schema, :record, :options

  def initialize(master_schema)
    self.master_schema = master_schema
  end

  def build(record)
    if record.respond_to?(:each)
      records = record # Making it easier to read
      # Build collection
      json = []

      # Preload all lookup associations to data store to prevent lookup rendering from N+1 query problem
      includes = []
      master_schema.entities.each do |entity|
        next unless entity.type?(:lookup) or entity.type?(:parent_lookup)

        includes << entity.association_name
      end

      records.includes(includes).each do |rec|
        json << build_record(rec)
      end
      json
    else
      build_record(record)
    end
  end

  def build_record(record)
    return nil if record.blank?

    json = {id: record.id}
    if master_schema.primary_entity_key.present?
      json[:display_name] = record.send(master_schema.primary_entity_key)
    end

    master_schema.entities.each do |entity|
      if entity.type?(:lookup) or entity.type?(:parent_lookup)
        json[entity.association_name] = build_lookup(record, entity)
      else
        json[entity.entity_key] = record.send(entity.entity_key)
      end
      json
    end

    json
  end

  def build_lookup(record, entity)
    record = record.send(entity.association_name)
    return nil if record.blank?

    # Compact will only render the id and name attributes
    record.as_json(compact: true)
  end

end
