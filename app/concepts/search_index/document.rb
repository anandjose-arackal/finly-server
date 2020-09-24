module SearchIndex::Document
  extend ActiveSupport::Concern

  class_methods do
    def register_search_index!(klass)
      klass.register(self)

      @search_index = klass
    end

    def search_index
      @search_index
    end

    def searchable_includes(*associations)
      @searchable_includes = associations if associations.present?
      @searchable_includes
    end
  end

  def searchable_document_data
    document = searchable_document
    return nil if document.nil?

    {id: searchable_record_id, record_id: id, record_type: searchable_record_type}.merge(searchable_document)
  end

  def searchable_record_id
    "#{searchable_record_type}_#{id}"
  end

  def searchable_record_type
    self.class.table_name
  end

  def searchable_document
    # Implement in the ActiveRecord
  end

  def show_in_search_index?
    deleted_at.nil?
  end

  def rebuild_search_index
    index_api = self.class.search_index
    return if index_api.blank?

    index = index_api.index
    if show_in_search_index?
      data = searchable_document_data
      return if data.blank?

      index.add_document searchable_document_data
    else
      index.delete_document searchable_record_id
    end
  end

end