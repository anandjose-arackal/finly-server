class SearchIndex::API
  include DynamicAttributes

  class_attr :index_name
  class_attr :primary_key

  def self.attribute(name, faceted: false, searchable: true, displayed: true, primary_key: false)
    attribute = SearchIndex::Attribute.new(name, faceted: faceted, searchable: searchable, displayed: displayed, primary_key: primary_key)
    attributes << attribute
    primary_key(attribute) if primary_key
    attribute
  end

  def self.register(model)
    models << model
  end

  def self.attributes
    @attributes ||= []
  end

  def self.models
    @models ||= []
  end

  def self.index
    validate

    self.new
  end

  def self.validate
    raise "Primary Key is not defined" if self.primary_key.blank?
    raise "Index Name is not defined" if self.index_name.blank?
  end

  def self.create_index
    validate

    begin
      index = Rails.configuration.meilisearch.create_index(self.index_name, primaryKey: self.primary_key.name)

      index.update_searchable_attributes(searchable_attributes)
      index.update_displayed_attributes(displayed_attributes)
      index.update_attributes_for_faceting(attributes_for_faceting)

      true
    rescue MeiliSearch::ApiError => e
      # Index already exists
      return false
      # raise e unless e.code == 'index_already_exists'
    end
  end

  def self.seed_index
    index = self.index
    models.each do |model|
      model.includes(model.searchable_includes).find_in_batches do |batch|
        data = []
        batch.each do |record|
          data << record.searchable_document_data if record.show_in_search_index?
        end
        index.add_documents data.compact
      end
    end

    true
  end

  def self.rebuild_index
    delete_index
    create_index
    seed_index
  end

  def self.searchable_attributes
    attributes.map { |attr| attr.name if attr.searchable }.compact
  end

  def self.displayed_attributes
    attributes.map { |attr| attr.name if attr.displayed }.compact
  end

  def self.attributes_for_faceting
    attributes.map { |attr| attr.name if attr.faceted }.compact
  end

  def self.delete_index
    begin
      Rails.configuration.meilisearch.delete_index(self.index_name)
      return true
    rescue MeiliSearch::ApiError => e
      # Index already exists
      return false
      # raise e unless e.code == 'index_already_exists'
    end
  end

  attr_accessor :index

  def initialize
    self.index = Rails.configuration.meilisearch.index(self.class.index_name)
  end

  def add_document(document)
    add_documents document
  end

  def add_documents(documents)
    documents = [documents] unless documents.respond_to?(:each)
    index.add_documents documents, self.class.primary_key.name
  end

  def delete_document(id)
    index.delete_documents(id)
  end

  def delete_documents(ids)
    ids = [ids] unless ids.respond_to?(:each)

    index.delete_documents(ids)
  end

  def get_all_update_status
    index.get_all_update_status
  end

  def search(q, filters: nil, facets: nil)
    options = {}
    options['filters'] = filters if filters.present?
    options['facetFilters'] = facets if facets.present?
    index.search(q, options)
  end

end