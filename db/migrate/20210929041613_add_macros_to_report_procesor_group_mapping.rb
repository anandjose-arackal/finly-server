class AddMacrosToReportProcesorGroupMapping < ActiveRecord::Migration[6.0]
  def change
    ErpSyncAttempt.setup_migration(ReportProcessorGroup)
  end
end
