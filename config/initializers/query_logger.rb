ENABLE_QUERY_LOGGER = Rails.env.production?
if ENABLE_QUERY_LOGGER
  ActiveRecord::ConnectionAdapters::AbstractAdapter.send(:prepend, ActiveRecordExt)
  QueryLogger.reset
end