class Transaction < Trailblazer::Operation
  include Contract::DSL, Model

  def assign_current_user!(options)
    options["model"].user = options['current_user'] || options[:current_user]
    options["model"].company = options["model"].user&.company
    true
  end

  def add_message(options, type, key, message)
    options["result.#{type}"] = {} if options["result.#{type}"].nil?
    options["result.#{type}"][key] = [] if options["result.#{type}"][key].nil?
    options["result.#{type}"][key] << message
  end

end