class Analytics::Master

  def self.register(model, olap_model)
    registry(model) << olap_model
  end

  def self.load!
    file_path = "#{Rails.root}/app/models/olap/**/*.rb"
    Dir[file_path].each { |f| load f }
    registry
  end

  def self.olap_models
    return @olap_models if @olap_models.present?

    @olap_models = []
    registry.values.each do |list|
      @olap_models += list
    end
    @olap_models
  end

  def self.registry(model = nil)
    @registry ||= {}
    return @registry unless model.present?

    @registry[model] ||= []
  end

  # def self.integrity_check!(after: nil, model: nil)
  #   all_olap_models = []
  #   if model.blank?
  #     registry.each { |transaction_model, olap_models| all_olap_models += olap_models }
  #   else
  #     all_olap_models += registry(model)
  #   end
  #   all_olap_models.each { |olap_model| sync olap_model, after: after }
  # end
  #
  # def self.sync(olap_model, after: nil)
  #   records = olap_model.transaction_model.all
  #   records = records.where('updated_at >= ?', (after - 1.minute)) if after.present?
  #   olap_model.transaction do
  #     records.find_in_batches do |batch|
  #       olap_record_map = {}
  #       olap_model.where(finly_ref_id: batch.pluck(:id)).each {|record| olap_record_map[record.finly_ref_id] = record}
  #       batch.each do |record|
  #         result = Analytics::Synchronizer::Persist.(params: {record: record, olap_model: olap_model, olap_record: olap_record_map[record.id]})
  #         next if result.success?
  #         next unless result[:in_sync]
  #         # Todo log error as sync failed
  #       end
  #     end
  #   end
  # end



end