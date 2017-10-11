if ['test', 'development'].include? Rails.env
  ActiveRecordQueryTrace.enabled = true
end