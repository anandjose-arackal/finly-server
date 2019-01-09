class ActiveRecord::ConnectionAdapters::Mysql2Adapter
  def supports_advisory_locks?
    false
  end
end