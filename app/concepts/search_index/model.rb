class SearchIndex::Model
  include DynamicAttributes

  def self.document_configs
    @document_configs ||= []
  end

  def self.index(index_api, &block)
    document_configs << SearchIndex::DocumentConfig.new(model, index_api, block)
  end

  def self.model
    Object.const_get(self.name[0..(self.name.size - "Index".length - 1)])
  end

  def self.index_record(record)
    document_configs.each do |document_config|
      document_config.index_record(record)
    end

    true
  end

  def self.rebuild_index(dry_run: false)
    document_configs.each do |document_config|
      document_config.rebuild_documents(dry_run: dry_run)
    end

    true
  end

end