class Macros::ErpSyncs::Create < Transactions::API

  schema do
    params do
      required(:id).filled
      required(:status).filled(inclusion?: ErpSyncStatus.values.map { |i| i.to_s })
      optional(:reference_id)
      optional(:message)
      optional(:attempted_at)
      required(:macro_id).filled
      required(:macro_job_id).filled
    end
  end

  step :init_record
  step :import_erp_syncs
  step Transactions::Messages::SuccessMessage('Saved')

  def init_record(context, record_class:, params:, current_user:, **)
    context[:records] = record_class.where(company_id: current_user.company_id, id: params[:id])

    true
  end

  def import_erp_syncs(context, records:, record_class:, params:, current_user:, **)
    status_id = ErpSyncStatus.id_for(params[:status])
    attempted_at = params[:attempted_at].present? ? DateTime.parse(params[:attempted_at]) : DateTime.now
    attempted_at = attempted_at.strftime("%Y-%m-%d")
    records.find_in_batches do |batch|
      erp_sync_params = []
      batch.each do |record|
        erp_sync_params << {
          company_id: current_user.company_id,
          status_id: status_id,
          reference_id: params[:reference_id],
          message: params[:message],
          attempted_at: attempted_at,
          record_id: record.id,
          record_type: record.class.name,
          macro_id: params[:macro_id],
          macro_job_id: params[:macro_job_id]
        }
      end
      ErpSyncAttempt.import erp_sync_params
    end
    records.update_all(
      "erp_sync_status_id=#{status_id}, erp_sync_message=#{params[:message]},erp_sync_reference_id=#{params[:reference_id]},erp_sync_attempted_at=#{attempted_at},erp_sync_attempts_count=Coalesce(erp_sync_attempts_count, 0) + 1"
    )

    true
  end

end