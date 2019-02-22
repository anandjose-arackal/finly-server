report = Report.find(7836)
report.document_level_reviewer_mappings.each do |dlrm|
  reviewer_id = dlrm.reviewer_id
  level_id = dlrm.level_id
  action_id = dlrm.action_id
  duplicate_dlrms = report.document_level_reviewer_mappings.where(reviewer_id: reviewer_id, level_id: level_id, action_id: action_id)
  latest_dlrm = duplicate_dlrms.reorder(created_at: :desc).first
  duplicate_dlrms.where.not(id: latest_dlrm.id).destroy_all
end