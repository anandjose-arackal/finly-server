module Searchkick::Api
  extend ActiveSupport::Concern

  # def self.scope(klass)
  #   scope = klass.unscoped.where(company_id: RequestStoreUtil.current_company&.id)
  #   if klass.reflect_on_association(:dlrms)
  #     scope = scope.includes({dlrms: [:taken_control_by, :action_taken_by, :forwarded_to, :forwarded_by, :rejected_by, :reviewer]})
  #   end
  #   scope
  # end

  included do
    searchkick index_name: -> {
      raise 'Current company should be set to identify the required index' unless RequestStoreUtil.current_company.present?

      [Rails.configuration.searchkick_prefix, RequestStoreUtil.current_company&.id, 'search', table_name].join('_')
    }

    scope :search_import_base, -> {
      raise 'Current company should be set to identify the required index' unless RequestStoreUtil.current_company.present?

      scope = unscoped.where(company_id: RequestStoreUtil.current_company.id)
      if klass.reflect_on_association(:dlrms)
        scope = scope.includes({dlrms: [:taken_control_by, :action_taken_by, :forwarded_to, :forwarded_by, :rejected_by, :reviewer]})
      end
      scope
    }

    scope :search_import, -> { search_import_base }
  end

  def should_index?
    deleted_at.nil? # only index active records
  end

  def search_data
    # Defaults to the models as_json for building search_data
    as_json
  end

  def collaborators
    document = {}
    if respond_to?(:dlrms)
      document[:collaborator_ids] = []
      document[:collaborator_emails] = []
      document[:collaborator_names] = []
      if created_by.present?
        document[:collaborator_ids] << created_by.id
        document[:collaborator_emails] << created_by.email
        document[:collaborator_names] << created_by.name

        document[:created_by_name] = created_by&.name
        document[:created_by_email] = created_by&.email
      end
      dlrms.each do |dlrm|
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
    end
    document
  end

end