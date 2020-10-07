class SearchIndex::Api
  include DynamicAttributes

  class_attr :index_name
  class_attr :primary_key

  def self.attribute(name, faceted: false, searchable: true, displayed: true, primary_key: false, crop_length: nil)
    attribute = SearchIndex::Attribute.new(name, faceted: faceted, searchable: searchable, displayed: displayed, primary_key: primary_key, crop_length: crop_length)
    attributes << attribute
    primary_key(attribute) if primary_key
    attribute
  end

  # Uses +SearchIndex::DocumentConfig+
  def self.register(document_config)
    document_configs << document_config
  end

  def self.attributes
    @attributes ||= []
  end

  def self.document_configs
    @document_configs ||= []
  end

  def self.index
    validate

    self.new
  end

  def self.validate
    raise "Primary Key is not defined" if self.primary_key.blank?
    raise "Index Name is not defined" if self.index_name.blank?
  end

  # Adds an env prefix to the index name if available.
  # This is used for generating a separate index per env within the same instance
  # Ex: dev1, dev2 can have separate index prefix to separate out the searches
  def self.full_index_name
    if Rails.configuration.meilisearch_index_prefix.present?
      return "#{Rails.configuration.meilisearch_index_prefix}_#{self.index_name}"
    end

    self.index_name
  end

  def self.create_index
    validate

    begin
      Rails.configuration.meilisearch.create_index(self.full_index_name, primaryKey: self.primary_key.name)

      true
    rescue MeiliSearch::ApiError => e
      # Index already exists
      return false
      # raise e unless e.code == 'index_already_exists'
    end
  end

  def self.seed_index(dry_run: false)
    document_configs.each do |document_config|
      document_config.rebuild_documents(dry_run: dry_run)
    end

    true
  end

  def self.rebuild_index(dry_run: false)
    delete_index
    create_index
    seed_index(dry_run: dry_run)
    set_index_properties
  end

  def self.set_index_properties
    index = Rails.configuration.meilisearch.index(self.full_index_name)
    index.update_searchable_attributes(searchable_attributes)
    index.update_displayed_attributes(displayed_attributes)
    index.update_attributes_for_faceting(attributes_for_faceting)
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
      Rails.configuration.meilisearch.delete_index(self.full_index_name)
      return true
    rescue MeiliSearch::ApiError => e
      # Index already exists
      return false
      # raise e unless e.code == 'index_already_exists'
    end
  end

  def self.attributes_to_crop
    return @attributes_to_crop if @attributes_to_crop.present?

    @attributes_to_crop = ["*"]
    attributes.each do |attr|
      next if attr.crop_length.nil?

      @attributes_to_crop << "#{attr.name}:#{attr.crop_length}"
    end
    @attributes_to_crop
  end

  attr_accessor :index

  def initialize
    self.index = Rails.configuration.meilisearch.index(self.class.full_index_name)
  end

  def add_document(document)
    add_documents document
  end

  def add_documents(documents)
    documents = [documents] unless documents.respond_to?(:each)
    SearchIndex::UpdateMonitor.with_tracking(self.class.full_index_name) do
      index.add_documents documents, self.class.primary_key.name
    end
  end

  def delete_document(id)
    SearchIndex::UpdateMonitor.with_tracking(self.class.full_index_name) do
      index.delete_documents(id)
    end
  end

  def delete_documents(ids)
    ids = [ids] unless ids.respond_to?(:each)

    SearchIndex::UpdateMonitor.with_tracking(self.class.full_index_name) do
      index.delete_documents(ids)
    end
  end

  def get_all_update_status
    index.get_all_update_status
  end

  def get_update_status(update_id)
    index.get_update_status(update_id)
  end

  def search(q, filters: nil, facets: nil, facets_distribution: nil, offset: 0, limit: 20)
    options = {}
    options['filters'] = filters if filters.present?
    options['facetFilters'] = facets if facets.present?
    options['facetsDistribution'] = facets_distribution if facets_distribution.present?
    options['attributesToHighlight'] = ['*'] if facets_distribution.present?
    options['attributesToCrop'] = self.class.attributes_to_crop if self.class.attributes_to_crop.present?
    options['matches'] = true
    options['offset'] = offset.to_i || 0
    options['limit'] = limit.to_i || 10
    SearchIndex::UpdateMonitor.with_tracking(self.class.full_index_name) do
      index.search(q, options)
    end
  end

end