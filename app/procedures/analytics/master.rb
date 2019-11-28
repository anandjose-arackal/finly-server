class Analytics::Master

  def self.register(model, klass)
    registry(model) << klass
  end

  def self.registry(model = nil)
    @registry ||= {}
    return @registry unless model.present?

    @registry[model] ||= []
  end

  def self.integrity_check!(after: nil, model: nil)
    mappers = []
    if model.blank?
      registry.each { |model, model_mappers| mappers += model_mappers }
    else
      mappers += registry(model)
    end
    mappers.each { |mapper| refresh mapper, after: after }
  end

  protected

  def self.refresh(mapper, after: nil)
    records = mapper.model.all
    records = records.where('updated_at >= ?', (after - 1.minute)) if after.present?
    records.find_each do |record|
      result = Analytics::Synchronizer.(params: {record: record, mapper: mapper})
      next if result.success?
      next unless result[:updated] == false
      # Todo log error as sync failed
    end
  end

end