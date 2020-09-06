# Anonymous Masters generated through {Models::MasterSchema} can have entities referencing other masters as associations.
# While generating the JSON at the time of rendering, unless this is explicitly included,
# it could lead to an N+1 query problem
#
# === Goals
#   1. Standardize the generated JSON for every master record
#   2. Prevent N+1 query problem that could arise
#   3. Build JSON for the associations.
#
# === JSON for associations
#   The associations will be generated as a hash having ID and Name fields. The name is picked up from the
#   +primary_entity_key+ defined in the {Models::MasterSchema} of the associated master
#
# @!attribute [rw] master_schema refers to the {Models::MasterSchema} of the record for which the JSON is being built
#   @return Models::MasterSchema
#
# @!attribute [rw] record refers to the {ApplicationRecord} or the collection ({ActiveRecord::Relation})
#
class Masters::JsonBuilder

  def self.call(master_schema, record)
    new(master_schema).build(record)
  end

  attr_accessor :master_schema, :record

  def initialize(master_schema)
    self.master_schema = master_schema
  end

  # Responsible for building JSON by iterating through the entities defined in the {Models::MasterSchema}
  #
  # === Preloading
  #   In case the input is a collection, +build+ method handles preloading of associated {Models::MasterEntity::Lookup}
  #   and {Models::MasterEntity::ParentLookup} entities. This is for handling the N+1 query issue which
  #   could arise from the lookup association
  #
  # @param [ApplicationRecord, ActiveRecord::Relation, Array] record is the record or the collection of records for the JSON has to be built
  #
  # @return [Hash, Array, nil]
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

  # Builds the JSON for an instance of {ApplicationRecord}.
  #
  # === Build process
  # 1. Every JSON will have an +id+ which refers to the database ID of the record
  # 2. +display_name+ Every JSON will have a display name which refers to the value of the +primary_entity_key+ of the {Models::MasterSchema}
  # 3. associated {Models::MasterEntity#entity_key} and equivalent value of the {Models::MasterSchema}
  #
  # @param [ApplicationRecord] record
  #
  # @return [Hash, nil]
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
