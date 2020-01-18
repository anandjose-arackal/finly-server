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

end