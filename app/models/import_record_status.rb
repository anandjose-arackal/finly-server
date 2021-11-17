class ImportRecordStatus < NonTenantedApplicationRecord
  include Seedable

  set_values :pending, :in_progress, :success, :failed
end
