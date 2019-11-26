class Analytics::Synchronizer
  include Events::Consumer
  include DynamicAttributes

  class_attr :master

  def self.setup(klass, events, sync: false)
    events.each do |event|
      Class.new(Analytics::Synchronizer) do
        consumes_event! event,
                        consumer_key: "analytics.synchronizer.#{event}",
                        name: "Analytics Synchronizer for #{event}",
                        options: {sync: sync}
        master klass
      end
    end
  end

  def auto_acknowledge?
    false
  end

  def on_event(user, payload)
    master = self.class.master
    input = master.input.call(user, payload)
    input = [input] unless input.respond_to?(:each)
    input.each do |record|
      sync = Analytics::Synchronizer::Job.(params: {record: record, master: master})
      unless sync.success?
        # Todo log failure with reason
        raise "Sync Error: #{sync.errors}}"
      end
    end
  end

  class Analytics::Synchronizer::Job < Transactions::API

    schema do
      params do
        required(:master).filled
        required(:record).filled
      end
    end

    skip_user_authorization!

    pass :init
    step :init_model
    step Contract::Build(builder: :contract_builder)
    step Contract::Validate()
    step Contract::Persist()

    def init(context, params:, **)
      context[:record] = params[:record]
      context[:master] = params[:master]
    end

    def init_model(context, params:, master:, record:, **)
      context[:model] = master.olap_model.find_or_initialize_by(finly_ref_id: record.id)
      return on_error context, :base, 'Model could not be initialized' if context[:model].nil?
      true
    end

    def contract_builder(context, master:, **)
      master.contract.new(context[:model])
    end

  end

end