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
    if params[:olap_model]
      options[:olap_models] << params[:olap_model]
    else
      options[:olap_models] = Analytics::Master.olap_models
    end
  end

  def sync(options, olap_models:, after:, **)
    olap_models.each do |olap_model|
      records = fetch_records(olap_model, after)
      records = records.includes(olap_model.required_relationships) if olap_model.required_relationships.present?
      records.find_in_batches do |batch|
        insert = []
        olap_record_map = {}
        olap_model.where(finly_ref_id: batch.pluck(:id)).each { |record| olap_record_map[record.finly_ref_id] = record }
        batch.each do |record|
          olap_record = olap_record_map[record.id]
          next if olap_record.present? and olap_record.in_sync?(record)

          # Initialize a new model here itself to prevent
          # find_or_initialize in Analytics::Synchronizer
          olap_record = olap_model.new(finly_ref_id: record.id) if olap_record.nil?
          result = Analytics::Synchronizer::Sync.(params: {record: record, olap_model: olap_model, olap_record: olap_record, skip_find: true})
          unless result.success?
            # Todo log error as sync failed
            next
          end

          insert << result[:model]
          # next unless result[:in_sync]
        end
        olap_model.import insert, on_duplicate_key_update: olap_model.field_mappings.map { |i| i[:primary_key] }
      end
    end
  end

  def fetch_records(olap_model, after)
    records = olap_model.transaction_model.all
    records = records.where('updated_at >= ?', (after - 1.minute)) if after.present?
    records
  end

end