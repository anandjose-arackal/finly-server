class SearchIndex::Index::DocumentBuilder
  include DynamicAttributes

  attr_accessor :model, :index_api, :block

  instance_attr :document_type
  instance_attr :features
  instance_attr :permissions
  instance_attr :category
  instance_attr :route
  instance_attr :layout

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
    @condition ||= lambda do |record|
      record.deleted_at.nil?
    end
  end

  def document_id(&block)
    @document_id = block if block_given?
    @document_id ||= lambda { |record|
      "#{(self.document_type || record.class.table_name)}_#{record.id}"
    }
  end

  def record_type(&block)
    @record_type = block if block_given?
    @record_type ||= lambda { |record|
      self.document_type || record.class.table_name
    }
  end

  def company_id(&block)
    @company_id = block if block_given?
    @company_id ||= lambda { |record|
      record.company_id.to_s
    }
  end

  def authorized?(current_user)
    return false unless current_user.present?
    return false unless permissions.blank? or current_user.has_permission?(permissions)
    return false unless company_subscribed?(current_user)

    true
  end

  def company_subscribed?(current_user)
    return true if self.features.blank?

    features([features]) unless features.respond_to?(:each)

    features.each do |feature|
      return false unless !!current_user.company.feature_subscription.send(feature)
    end

    true
  end

  def rebuild_documents(dry_run: false)
    model.includes(include_associations).find_in_batches do |batch|
      data = []
      batch.each do |record|
        next if condition.present? and not condition.call(record)
        record_data = build_record_data(record)
        next if record_data.blank?

        data << record_data
      end
      index_api.index.add_documents data.compact
      break if dry_run

      # This is to avoid Net::ReadTimeout (Net::ReadTimeout)
      sleep 1
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
    return if document.nil?

    document[:company_id] = company_id.call(record).to_s
    return if document[:company_id].blank?
    # raise 'Company ID is mandatory for building search index' if document[:company_id].blank?

    document.each do |k, v|
      v.compact! if v.respond_to?(:compact)
      v.uniq! if v.respond_to?(:uniq!)
      if v.respond_to?(:each)
        document[k] = v.join(', ')
      end
    end
    document.compact!
    {id: document_id.call(record), record_id: record.id, record_type: record_type.call(record)}.merge(document)
  end

end