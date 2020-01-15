class Analytics::Mapper::EventHandler
  include Events::Consumer
  include DynamicAttributes

  class_attr :mapper_klass

  def self.build(mapper, event)
    Class.new(self) do
      consumes_event!(event, consumer_key: "analytics.synchronizer.#{event}", name: "Analytics Synchronizer for #{event}", sync: mapper.sync?)
      mapper_klass(mapper)
    end
  end

  def mapper_klass
    self.class.mapper_klass
  end

  def on_event(user, payload)
    olap_model = mapper_klass.olap_model || self.mapper_klass
    input = olap_model.input.call(user, payload)
    input = [input] unless input.respond_to?(:each)
    input.each do |record|
      sync = Analytics::Synchronizer::Persist.(params: {record: record, olap_model: olap_model, payload: payload})
      if sync.failure? and not sync[:in_sync]
        # Todo log failure with reason
        raise "Sync Error: #{sync.errors}}"
      end
    end
    Success()
  end
end