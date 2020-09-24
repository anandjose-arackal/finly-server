module SearchIndex::Document
  extend ActiveSupport::Concern

  class_methods do
    def register_search_index!(klass)
      klass.register(self)
    end

    def searchable_includes(*associations)
      @searchable_includes = associations if associations.present?
      @searchable_includes
    end
  end

  def searchable_document
    # Implement in the ActiveRecord
  end

  def show_in_search_index?
    deleted_at.nil?
  end

end