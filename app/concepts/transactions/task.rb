class Transactions::Task

  def self.build(config = {}, &block)
    # Custom implementation based on Trailblazer::Activity::TaskBuilder::Task. Task was only passing context and
    # not context, options. Hence the custom implementation
    task = -> ((context, flow_options), **circuit_options) do
      result = block.call(context, flow_options, circuit_options)

      signal = Trailblazer::Activity::TaskBuilder.binary_signal_for(result, Trailblazer::Activity::Right, Trailblazer::Activity::Left)

      return signal, [context, flow_options]
    end
    # task = Trailblazer::Activity::TaskBuilder::Task.new(-> (context, circuit_options) {block.call(context, circuit_options)}, id)
    config.merge({task: task})
  end

  def self.Run(klass: nil, builder: nil, params_builder: nil)
    Transactions::Task.build id: "messages.success.add" do |context, flow_options, circuit_options|
      if klass

      elsif builder

      end
    end
  end

  class Runner

    def self.with_klass(klass, context, circuit_options, params_builder: nil)
      if params_builder
        params = circuit_options[:exec_context].send(params_builder)
      else
        params = {params: context[:params], current_user: context[:current_user]}
      end
      @op = klass.(params)
      # Todo evaluation of the response for success/failure
    end

    def self.with_builder(builder, context, circuit_options, params_builder: nil)
      @op = circuit_options[:exec_context].send(context)
    end

  end

end