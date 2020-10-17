class SearchIndex::Index::Api
  include DynamicAttributes

  class_attr :index_name
  class_attr :primary_key
  class_attr :document_builder, default: SearchIndex::Index::DocumentBuilder

  def self.attribute(name, faceted: false, searchable: true, displayed: true, primary_key: false, crop_length: nil)
    attribute = SearchIndex::Index::Attribute.new(name, faceted: faceted, searchable: searchable, displayed: displayed, primary_key: primary_key, crop_length: crop_length)
    attributes << attribute
    primary_key(attribute) if primary_key
    attribute
  end

  # Uses +SearchIndex::Index::DocumentBuilder+
  def self.register(document_builder)
    document_builders << document_builder
  end

  def self.attributes
    @attributes ||= []
  end

  def self.document_builders
    @document_builders ||= []
  end

  def self.index(company_id)
    validate

    self.new(company_id)
  end

  def self.validate
    raise "Primary Key is not defined" if self.primary_key.blank?
    raise "Index Name is not defined" if self.index_name.blank?
  end

  # Adds an env prefix to the index name if available.
  # This is used for generating a separate index per env within the same instance
  # Ex: dev1, dev2 can have separate index prefix to separate out the searches
  def self.scoped_index_name(company_id)
    scoped_index_name = "#{self.index_name}_#{company_id}"
    return scoped_index_name unless Rails.configuration.meilisearch_index_prefix.present?

    "#{Rails.configuration.meilisearch_index_prefix}_#{scoped_index_name}"
  end

  def self.create_index(company_id)
    validate

    begin
      Rails.configuration.meilisearch.create_index(scoped_index_name(company_id), primaryKey: self.primary_key.name)
      set_index_properties(company_id)
      true
    rescue MeiliSearch::ApiError => e
      # Index already exists
      return false
      # raise e unless e.code == 'index_already_exists'
    end
  end

  def self.seed_index(company_id, dry_run: false)
    indexed_records = 0
    document_builders.each do |document_builder|
      indexed_records += document_builder.rebuild_documents(company_id, dry_run: dry_run)
    end

    indexed_records
  end

  def self.rebuild_logger
    @rebuild_logger ||= LogStashLogger.new(type: :file, path: 'log/meilisearch_rebuild_tracker.log', sync: true)
  end

  def self.rebuild_index(dry_run: false)
    dt1 = DateTime.now
    t1 = Time.now
    rebuild_logger.info({event: "Rebuilding Index", action: "Starting Rebuild"})
    indexed_records = 0
    companies = Company.all.reorder(id: :asc)
    companies = companies.limit(2) if dry_run

    companies.pluck(:id).each do |company_id|
      delete_index(company_id)
      create_index(company_id)
      indexed_records += seed_index(company_id, dry_run: dry_run)
    end

    rebuild_attributes = {
        started_at: dt1,
        ended_at: DateTime.now,
        total_time: Time.at(Time.now - t1).utc.strftime("%H:%M:%S.%L"),
        total_indexed_records: indexed_records
    }
    SearchIndex::Services::UpdateMonitor.logger.info({message_type: 'index_rebuild'}.merge(rebuild_attributes))

    rebuild_logger.info({event: "Rebuilding Index", action: "Rebuild Completed"}.merge(rebuild_attributes))

    true
  end

  def self.set_index_properties(company_id)
    index = Rails.configuration.meilisearch.index(scoped_index_name(company_id))
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

  def self.delete_index(company_id)
    begin
      Rails.configuration.meilisearch.delete_index(scoped_index_name(company_id))
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

  attr_accessor :index, :company_id

  def initialize(company_id)
    self.company_id = company_id
    self.index = Rails.configuration.meilisearch.index(scoped_index_name)
  end

  def scoped_index_name
    self.class.scoped_index_name(company_id)
  end

  def add_documents(documents)
    documents = [documents] unless documents.respond_to?(:each)
    SearchIndex::Services::UpdateMonitor.with_tracking(scoped_index_name) do
      index.add_documents documents, self.class.primary_key.name
    end
  end
  alias_method :add_document, :add_documents

  def delete_document(id)
    SearchIndex::Services::UpdateMonitor.with_tracking(scoped_index_name) do
      index.delete_documents(id)
    end
  end

  def delete_documents(ids)
    ids = [ids] unless ids.respond_to?(:each)

    SearchIndex::Services::UpdateMonitor.with_tracking(scoped_index_name) do
      index.delete_documents(ids)
    end
  end

  def get_all_update_status
    index.get_all_update_status
  end

  def get_update_status(update_id)
    index.get_update_status(update_id)
  end

  def total_enqueued
    status_counts&.dig('enqueued') || 0
  end

  # Provides a status wise summary of the update_status
  def status_counts
    index.get_all_update_status.map { |i| i['status'] }.inject(Hash.new(0)) { |h, e| h[e] += 1; h }
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
    SearchIndex::Services::UpdateMonitor.with_tracking(scoped_index_name) do
      begin
        index.search(q, options)
      rescue MeiliSearch::ApiError => e
        # In case the index is not created
        {
            'hits' => []
        }
      end
    end
  end

end