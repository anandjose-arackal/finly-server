class YesBankVendorExposure < Exposures::API
  include Concerns::ErpSyncConcern
  
  attribute :id, record_attribute: true
  attribute :name, record_attribute: true
  attribute :email, record_attribute: true
  attribute :business_name, record_attribute: true
  attribute :trade_name, record_attribute: true
  attribute :vendor_id, record_attribute: true
  attribute :vendor_country, record_attribute: true
  attribute :vendor_type, record_attribute: true, exposure: true
  attribute :rcm_enabled, record_attribute: true
  attribute :pan, record_attribute: true
  attribute :msme_registered, record_attribute: true
  attribute :msme_registration_number, record_attribute: true
  attribute :submitted_at, record_attribute: true
  attribute :approved_at, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :updated_at, record_attribute: true
  attribute :created_by, record_attribute: true, exposure: true
  attribute :created_by_id, record_attribute: true
  attribute :policy, record_attribute: true, exposure: true
  attribute :status, record_attribute: true, exposure: true
  attribute :gst_registered, record_attribute: true
  attribute :authorized, record_attribute: true
  attribute :gl_name do
    record.business_name
  end
  # Have to do this because vendor_country in vendor model is just a string. Need to do this to get the value in lookups
  attribute :vendor_country_id do
    record.vendor_country == 'India' ? 78 : 196
  end
  attribute :vendor_country_id_value do
    record.vendor_country == 'India' ? 'India' : 'International'
  end
  attribute :payment_term, record_attribute: true, exposure: true
  attribute :display_name, record_attribute: true
  attribute :mobile_number, record_attribute: true
  attribute :state_code, record_attribute: true, exposure: true
  attribute :description, record_attribute: true
  attribute :address, record_attribute: true

  attribute :bank_accounts, includes: [:bank_accounts], exposure: true do
    record.bank_accounts.unscope(:order).order(default_account: :desc, created_at: :desc)
  end

  attribute :default_bank_account, includes: [:bank_accounts], exposure: true do
    record.bank_accounts.default_accounts&.first
  end

  attribute :gstin_location, includes: [:gstin_locations], exposure: true do
    record.gstin_locations&.first
  end
  attribute :gstin_locations, includes: [:gstin_locations], exposure: true, record_attribute: true

  attribute :deactivated, record_attribute: :deactivated?

  attribute :approved_trails, exposure: :true,  includes: [:trails] do
    record.trails.where(action_id: TrailAction.id_for(:approve))
  end

  attribute :tds_rates_list, record_attribute: true, exposure: true
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

  attribute :approvers, includes: [{dlrms: [:taken_control_by, :forwarded_to, :reviewer]}] do
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

  attribute :approval_pending_reviewers, includes: [:level, :document_level_reviewer_mappings] do
    record.get_reviewers&.map(&:name)&.join(", ")
  end

  attribute :rejection_comments, includes: [:trails] do
    trail_texts =[]
    record.trails.only_reject.each do |trail|
      trail_texts  << trail.generate_trail_body_note(nil)
    end
    trail_texts.compact.join(', ')
  end
end
