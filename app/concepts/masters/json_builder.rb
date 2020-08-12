# Masters::JsonBuilder is built for fixing N+1 query problems that could arise with dynamically masters.
# The challenge is that since all masters are dynamically generated, we cannot add a belongs_to, has_one, has_many relationships
# when one master refers another master. For this purpose, Masters::JsonBuilder maintains a data provider
# which pre-loads all the associations to avoid N+1 query problem.
# Flow:
#   build
#     -> pre-load all the records from lookup fields
#     -> build json for each of the records
class Masters::JsonBuilder

  def self.call(master_schema, record, data_provider: nil)
    build master_schema, record, data_provider: data_provider
  end

  def self.build(master_schema, record, data_provider: nil)
    data_provider = DataProvider.new(master_schema.company) if data_provider.nil?

    if record.respond_to?(:each)
      # Build collection
      json = []
      master_schema.entities.each do |entity|
        if entity.type == 'MasterEntity::Lookup'
          data_provider.pre_load(record, lookup_master_key(entity), entity.entity_key)
        end
      end
      record.each do |rec|
        json << build_record(master_schema, rec, data_provider)
      end
      json
    else
      build_record(master_schema, record, data_provider)
    end
  end

  def self.build_record(master_schema, record, data_provider)
    return nil if record.blank?

    json = {id: record.id}
    master_schema.entities.each do |entity|
      case entity.type
      when 'MasterEntity::Lookup'
        json[entity.entity_key] = build(
            data_provider.find_master_schema(lookup_master_key(entity)),
            data_provider.find_record(
                lookup_master_key(entity),
                record.send(entity.entity_key)
            )
        )
      else
        json[entity.entity_key] = record.send(entity.entity_key)
      end
    end
    json
  end

  def self.lookup_master_key(entity)
    entity.choices_scope.route.split(".").last
  end

  class DataProvider

    attr_accessor :company

    def initialize(company)
      self.company = company
    end

    def find_record(master_key, record_id)
      records&.dig(master_key, record_id)
      # record = records&.dig(master_key, record_id)
      # return record if record.present?
      #
      # master_schema = find_master_schema(master_key)
      # master_model_class = master_schema.record_model_class
      # record = master_model_class.find_by(id: record_id)
      # return nil if record.blank?
      #
      # self.records(master_key)[record.id] = record
      # record
    end

    def find_master_schema(master_key)
      return master_schemas[master_key] if master_schemas[master_key].present?

      master_schemas[master_key] = MasterSchema.find_by(company: company, master_key: master_key)
    end

    def master_schemas
      @master_schemas ||= {}.with_indifferent_access
    end

    def records(master_key=nil)
      @records ||= {}.with_indifferent_access
      return @records if master_key.nil?

      @records[master_key] ||= {}.with_indifferent_access
    end

    def pre_load(records, master_key, entity_key)
      master_schema = find_master_schema(master_key)
      # Un-scope to support retrieved soft-deleted records
      associated_records = master_schema.record_model_class.unscoped.where("id in (?)", records.pluck(entity_key))
      associated_records.each do |record|
        self.records(master_key)[record.id] = record
      end
    end

  end

end
