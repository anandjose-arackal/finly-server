class Transactions::Helper

  def self.options_to_args(parameters, options)
    arguments = []
    parameters.each do |params|
      key = params[1]
      var = options[key] || options[key.to_s]
      arguments << var
    end
    arguments.shift
    arguments
  end

end