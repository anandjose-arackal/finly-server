ENABLE_QUERY_LOGGER = Rails.env.production?
# ENABLE_QUERY_LOGGER = true
if ENABLE_QUERY_LOGGER
  ActiveRecord::ConnectionAdapters::AbstractAdapter.send(:prepend, ActiveRecordExt)
  QueryLogger.reset
end