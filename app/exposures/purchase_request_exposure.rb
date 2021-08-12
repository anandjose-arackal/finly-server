class PurchaseRequestExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :request_id do
    record.order_number
  end
  attribute :description, record_attribute: true
  attribute :status, exposure: true, record_attribute: true
  attribute :department, exposure: true, record_attribute: true
  attribute :location, exposure: true, record_attribute: true
  attribute :cost_center, exposure: true, record_attribute: true
  attribute :total_amount, exposure: true, record_attribute: true
  attribute :created_by, exposure: true, record_attribute: :creator
  attribute :created_by_id, record_attribute: :creator_id
  attribute :policy, exposure: true, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :updated_at, record_attribute: true
  attribute :submitted_at, record_attribute: true
  attribute :approved_at, record_attribute: true
  attribute :cost_allocation_items, record_attribute: true
  attribute :items, record_attribute: true, exposure: true
  attribute :controlling_level, record_attribute: true, exposure: true, includes: [:controlling_level]
  attribute :get_reviewers_names do
    record.get_reviewers&.map(&:name)&.join(", ")
  end
  attribute :approved_reviewers_names, includes: [{ dlrms: :reviewer }] do
    record.dlrms&.where(action_id: TrailAction.id_for(:approve))&.includes(:reviewer)&.map {|dlr| dlr&.reviewer&.name}&.join(" ,")
  end

  attribute :approved_timeline, includes: [{dlrms: [:taken_control_by, :forwarded_to, :reviewer]}] do
    approvers = record.dlrms.map do |dlrm|
      taken_control_by = forwarded_to = reviewer = nil
      taken_control_by = dlrm.taken_control_by
      forwarded_to = dlrm.forwarded_to
      reviewer = dlrm.reviewer
      approved = [TrailAction.id_for(:approve), TrailAction.id_for(:approve_and_forward)].include?(dlrm.action_id)
      action_taken = (dlrm.action_taken_at.present? ? dlrm.action_taken_at.strftime("%I:%M %p, %d %b %Y") : dlrm.updated_at.strftime("%I:%M %p, %d %b %Y"))
      if forwarded_to.present?
        (approved ? "#{forwarded_to.name} - #{action_taken}" : forwarded_to.name)
      elsif taken_control_by.present?
        (approved ? "#{taken_control_by.name} - #{action_taken}" : taken_control_by.name)
      elsif reviewer.present?
        (approved ? "#{reviewer.name} - #{action_taken}" : reviewer.name)
      end
    end
    approvers.reject { |e| e.to_s.empty? }.join(", ")
  end

end