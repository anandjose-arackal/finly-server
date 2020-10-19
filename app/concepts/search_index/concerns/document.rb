module SearchIndex::Concerns::Document
  extend ActiveSupport::Concern

  included do
    # Fixme : Ideally the respective SearchIndex DocumentConfig class should be loaded for development env using Loader, but since it is throwing a superclass mismatch, this is a temporary workaround where the classes are loaded through the model
    search_index
  end

  class_methods do
    def search_index
      Object.const_get("#{self.name}Index")
    end

    def rebuild_search_index(dry_run: false)
      search_index.rebuild_index(dry_run: dry_run)
    end
  end

  def search_index
    self.class.search_index
  end

end