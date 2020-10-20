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
    searchkick callbacks: :queue

    scope :search_import, -> {
      # raise 'Current company should be set to identify the required index' unless RequestStoreUtil.current_company.present?

      scope = unscoped #.where(company_id: RequestStoreUtil.current_company.id)
      if klass.reflect_on_association(:dlrms)
        scope = scope.includes({dlrms: [:taken_control_by, :action_taken_by, :forwarded_to, :forwarded_by, :rejected_by, :reviewer]})
      end
      scope.searchkick_import.limit(100)
    }

    scope :searchkick_import, -> {}
  end

  def should_index?
    deleted_at.nil? # only index active records
  end

  def search_data
    data = {
        company_id: self.company_id,
        record_type: self.class.searchkick_record_type
    }.merge(searchkick_data).merge(search_collaborators_data)
    return nil if data[:company_id].nil?

    data
  end

  def searchkick_data
    # Defaults to the models as_json for building search_data
    as_json
  end

  def search_collaborators_data
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

  class_methods do
    def searchkick_record_type(value = NoObject)
      @searchkick_record_type = value unless value == NoObject
      @searchkick_record_type&.to_s || self.table_name
    end
  end

end