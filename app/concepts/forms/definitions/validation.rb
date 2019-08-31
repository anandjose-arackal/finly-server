class Forms::Definitions::Validation
  attr_accessor :args, :block

  def initialize(*args, &block)
    self.args = args
    self.block = block
  end

end