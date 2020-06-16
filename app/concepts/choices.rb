module Choices

  def self.[](key)
    Choices::Builder.choice_handlers[key]
  end

end