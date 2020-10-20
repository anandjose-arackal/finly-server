module Searchkick::Api
  extend ActiveSupport::Concern

  class Searchkick::Api::EnqueueReindex
    include Sidekiq::Worker

    def perform(klass_name, record_id)
      Object.const_get(klass_name).searchkick_index(name: nil).reindex_queue.push(record_id)
    end

  end

  included do
    scope :search_import, -> {
      # raise 'Current company should be set to identify the required index' unless RequestStoreUtil.current_company.present?

      scope = include_soft_deleted #.where(company_id: RequestStoreUtil.current_company.id)
      if klass.reflect_on_association(:dlrms)
        scope = scope.includes({dlrms: [:taken_control_by, :action_taken_by, :forwarded_to, :forwarded_by, :rejected_by, :reviewer]})
      end
      scope.searchkick_import#.limit(1000)
    }

    searchkick callbacks: :queue,
               searchable: searchkick_api.searchable_fields, filterable: searchkick_api.filterable_fields

    scope :searchkick_import, -> {
      if searchkick_api.scope.present?
        instance_eval &searchkick_api.scope
      end
    }

    # Since paranoid is not triggering after_commit callback when a record is destroy, manually setting a job to publish to queue in 15seconds
    after_destroy do
      Searchkick::Api::EnqueueReindex.perform_in(15, self.class.name, self.id)
    end
  end

  class_methods do
    def searchkick_api
      Object.const_get("#{self.name}Index")
    end
  end

  def searchkick_api
    self.class.searchkick_api
  end

  def should_index?
    searchkick_api.should_index?(self)
  end

  def search_data
    searchkick_api.search_data(self)
  end

  class Searchkick::Api::DSL
    include DynamicAttributes

    class_attr :fields, default: {}
    class_attr :record_type

    def self.scope(&block)
      @scope = block if block_given?
      @scope
    end

    def self.field(key, value: nil, searchable: true, filterable: true, displayable: true, includes: [])
      value ||= key
      fields[key] = {key: key, value: value, searchable: searchable, filterable: filterable, displayable: displayable, includes: includes}
    end

    def self.searchable_fields
      fields.values.map { |field_config| field_config[:key].to_s if field_config[:searchable] }.compact + %w(record_type)
    end

    def self.filterable_fields
      fields.values.map { |field_config| field_config[:key].to_s if field_config[:filterable] }.compact + %w(record_type record_id company_id collaborator_names collaborator_emails collaborator_ids created_by_email created_by_name)
    end

    def self.displayable_fields
      fields.values.map { |field_config| field_config[:key].to_s if field_config[:displayable] }.compact + %w(record_type record_id collaborator_names collaborator_emails collaborator_ids created_by_email created_by_name)
    end

    def self.should_index?(record)
      record.deleted_at.nil?
    end

    def self.search_data(record)
      data = {
          company_id: record.company_id,
          record_type: record.class.searchkick_api.record_type,
          record_id: record.id
      }.merge(searchkick_data(record)).merge(search_collaborators_data(record))
      return nil if data[:company_id].nil?

      # If the value is an array, ensure it is unique
      data.each do |k, v|
        v.uniq! if v.is_a?(Array)
      end

      data
    end

    def self.searchkick_data(record)
      data = {}
      exposure = record.to_exposure
      fields.each do |field_key, config|

        value = config[:value]
        if value.is_a?(Proc)
          value = instance_exec record, &value
        end

        if value.is_a?(String)
          value = exposure.template(value)
        elsif value.is_a?(Symbol)
          if record.respond_to?(value)
            value = record.send(value)
          else
            value = exposure.send(value)
          end
        end
        data[field_key] = value
      end
      data
    end

    def self.search_collaborators_data(record)
      return {} unless record.respond_to?(:dlrms)

      document = {}
      document[:collaborator_ids] = []
      document[:collaborator_emails] = []
      document[:collaborator_names] = []
      if record.created_by.present?
        document[:collaborator_ids] << record.created_by.id
        document[:collaborator_emails] << record.created_by.email
        document[:collaborator_names] << record.created_by.name

        document[:created_by_name] = record.created_by&.name
        document[:created_by_email] = record.created_by&.email
      end
      record.dlrms.each do |dlrm|
        if dlrm.taken_control_by.present?
          document[:collaborator_ids] << dlrm.taken_control_by.id
          document[:collaborator_names] << dlrm.taken_control_by.name
          document[:collaborator_emails] << dlrm.taken_control_by.email
        end

        if dlrm.reviewer.present?
          document[:collaborator_ids] << dlrm.reviewer.id
          document[:collaborator_names] << dlrm.reviewer.name
          document[:collaborator_emails] << dlrm.reviewer.email
        end

        if dlrm.forwarded_to.present?
          document[:collaborator_ids] << dlrm.forwarded_to.id
          document[:collaborator_names] << dlrm.forwarded_to.name
          document[:collaborator_emails] << dlrm.forwarded_to.email
        end

        if dlrm.forwarded_by.present?
          document[:collaborator_ids] << dlrm.forwarded_by.id
          document[:collaborator_names] << dlrm.forwarded_by.name
          document[:collaborator_emails] << dlrm.forwarded_by.email
        end

        if dlrm.rejected_by.present?
          document[:collaborator_ids] << dlrm.rejected_by.id
          document[:collaborator_names] << dlrm.rejected_by.name
          document[:collaborator_emails] << dlrm.rejected_by.email
        end
      end
      document
    end
  end

end