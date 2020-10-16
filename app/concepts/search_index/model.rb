class SearchIndex::Model
  include DynamicAttributes

  def self.document_builders
    @document_builders ||= []
  end

  def self.index(index_api, &block)
    document_builders << index_api.document_builder.new(model, index_api, block)
  end

  def self.model
    Object.const_get(self.name[0..(self.name.size - "Index".length - 1)])
  end

  def self.index_record(record)
    document_builders.each do |document_builder|
      document_builder.index_record(record)
    end

    true
  end

  def self.rebuild_index(dry_run: false)
    document_builders.each do |document_builder|
      document_builder.rebuild_documents(dry_run: dry_run)
    end

    true
  end

end