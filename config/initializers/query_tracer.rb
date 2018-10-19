if ['test', 'development'].include? Rails.env
  ActiveRecordQueryTrace.enabled = false
end