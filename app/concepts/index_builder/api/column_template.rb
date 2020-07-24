# Standard set of columns that can be reused across most documents/records
class IndexBuilder::API::ColumnTemplate

  def self.ControllingUser(klass)
    klass.column :controlling_user, default: true, includes: [:document_level_reviewer_mappings, :level] do
      user value: -> (context) { context[:record].get_reviewers.first }
      text value: -> (context) do
        count = context[:record].get_reviewer_ids.count
        if count > 2
          "+ #{count} Reviewers"
        else
          # To avoid FE from keeping a dashed (--) placeholder
          " "
        end
      end
    end
  end

  def self.ControllingLevel(klass)
    klass.column :controlling_level, default: true, includes: [:controlling_level] do
      text value: "{{record.controlling_level.name}}"
      text value: -> (context) do
        if context[:record].review_in_progress? and context[:record].controlling_level.present?
          "Level: #{context[:record].controlling_level.level_number}"
        else
          " "
        end
      end
    end
  end

  def self.ReviewProgress(klass)
    klass.column :progress, label: 'Approval Progress', default: true, includes: [:document_level_reviewer_mappings] do
      progress_bar value: ->(context) { context[:record].review_progress || 0 },
                   completed_count: ->(context) { context[:record].reviewers_completed_count || 0 },
                   total_count: ->(context) { context[:record].reviewers_count || 0 }
    end
  end

  def self.ErpSync(klass)
    klass.column :erp_sync_status, label: "ERP Sync Status", default: false do
      indicator value: "{{record.erp_sync_status.name}}", format: -> (context) {
        case context[:record].erp_sync_status_id
        when ErpSyncStatus.id_for(:pending)
          format = 'warning'
        when ErpSyncStatus.id_for(:in_progress)
          format = 'info'
        when ErpSyncStatus.id_for(:synced)
          format = 'success'
        when ErpSyncStatus.id_for(:failed)
          format = 'danger'
        else
          format = 'warning'
        end
        format
      }
    end

    klass.column :erp_sync_message, label: 'ERP Sync Message', default: false do
      text value: :erp_sync_message
    end

    klass.column :erp_sync_reference_id, label: 'ERP Sync Reference ID', default: false do
      text value: :erp_sync_reference_id
    end

    klass.column :erp_sync_attempted_at, label: 'ERP Sync Attempted At', default: false do
      text value: -> (context) {context[:record].erp_sync_attempted_at&.strftime('%I:%M %p, %d %b %Y')}
    end

    klass.column :erp_sync_attempts, label: 'ERP Sync Attempts', default: false do
      text value: :erp_sync_attempts_count
    end
  end
end