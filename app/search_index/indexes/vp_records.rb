class Indexes::VpRecords < SearchIndex::Api

  index_name 'vp_records'

  attribute :id, primary_key: true, searchable: false, displayed: false
  attribute :company_id, faceted: true, displayed: false
  attribute :record_id, searchable: false, displayed: true
  attribute :record_type, faceted: true, searchable: false, displayed: true
  attribute :sequence_id
  attribute :description
  attribute :line_items
  attribute :category_code
  attribute :category_name
  attribute :gl_code
  attribute :cost_center_name
  attribute :cost_center_code
  attribute :department_name
  attribute :department_code
  attribute :location_name
  attribute :location_code
  attribute :narration
  attribute :billing_location
  attribute :shipping_location
  attribute :submitted_at
  attribute :approved_at
  attribute :status_id, searchable: false, displayed: false
  attribute :status_name
  attribute :vendor_name
  attribute :vendor_trade_name
  attribute :vendor_sequence_id
  attribute :tax_id
  attribute :tax_registration_number
  attribute :policy_id, searchable: false, displayed: false
  attribute :policy_name
  attribute :collaborators_ids, displayed: false
  attribute :collaborators_emails
  attribute :collaborators_names

  class Indexes::VpRecords::Helpers

    INCLUDE_COLLABORATORS = {dlrms: [:taken_control_by, :action_taken_by, :forwarded_to, :forwarded_by, :rejected_by, :reviewer]}

    def self.Collaborators(record)
      document = {}
      if record.respond_to?(:dlrms)
        document[:collaborator_ids] = []
        document[:collaborator_emails] = []
        document[:collaborator_names] = []
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
        document[:collaborator_ids].uniq!
        document[:collaborator_names].uniq!
        document[:collaborator_emails].uniq!
      end
      document
    end

  end

end
