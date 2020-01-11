class Analytics::IntegrityCheck < Transactions::API

  schema do
    params do
      optional(:olap_model)
      optional(:after)
    end
  end

  skip_user_authorization!

  pass :init
  pass :sync

  def init(options, params:, **)
    options[:after] = params[:after]
    options[:olap_models] = []
    if params[:olap_models]
      options[:olap_models] << params[:olap_model]
    else
      Analytics::Master.registry.values.each do |list|
        options[:olap_models] += list
      end
    end
  end

  def sync(options, olap_models:, after:, **)
    olap_models.each do |olap_model|
      records = olap_model.transaction_model.all
      records = records.where('updated_at >= ?', (after - 1.minute)) if after.present?
      records.find_in_batches do |batch|
        insert = []
        olap_record_map = {}
        olap_model.where(finly_ref_id: batch.pluck(:id)).each { |record| olap_record_map[record.finly_ref_id] = record }
        batch.each do |record|
          result = Analytics::Synchronizer.(params: {record: record, olap_model: olap_model, olap_record: olap_record_map[record.id], skip_find: true, persist: false})
          insert << result[:model] if result.success? and not result[:in_sync]
          next if result.success?
          next unless result[:in_sync]
          # Todo log error as sync failed
        end
        olap_model.import insert, on_duplicate_key_update: olap_model.field_mappings.map {|i| i[:primary_key]}
      end
    end
  end

end