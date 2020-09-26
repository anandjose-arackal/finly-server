class SearchIndex::DocumentConfig

  attr_accessor :model, :index_api, :block

  def initialize(model, index_api, block)
    self.model = model
    self.index_api = index_api
    index_api.register(self)
    instance_eval &block
  end

  def include_associations(*associations)
    @include_associations = associations if associations.present?
    @include_associations ||= []
  end

  def serialize(&block)
    @serialize = block if block_given?
    @serialize
  end

  def condition(&block)
    @condition = block if block_given?
    @condition
  end

  def document_id(&block)
    @document_id = block if block_given?
    @document_id ||= lambda { |record|
      "#{record.class.table_name}_#{record.id}"
    }
  end

  def record_type(&block)
    @record_type = block if block_given?
    @record_type ||= lambda { |record|
      record.class.table_name
    }
  end

  def rebuild_documents
    model.includes(include_associations).find_in_batches do |batch|
      data = []
      batch.each do |record|
        record_data = build_record_data(record)
        next if record_data.blank?

        data << record_data if condition.blank? or condition.call(record)
      end
      index_api.index.add_documents data.compact
    end
  end

  def index_record(record)
    index = index_api.index
    if condition.blank? or condition.call(record)
      data = build_record_data(record)
      return if data.blank?

      index.add_document data
    else
      id = document_id.call(record)
      index.delete_document id
    end
  end

  def build_record_data(record)
    return nil if serialize.nil?

    document = serialize.call(record)
    raise 'Company ID is mandatory for building search index' if document[:company_id].blank?

    {id: document_id.call(record), record_id: record.id, record_type: record_type.call(record)}.merge(document)
  end

end