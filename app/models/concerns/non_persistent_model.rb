class NonPersistentModel < ApplicationRecord
  self.abstract_class = true

  def initialize(attributes= {})
    pre_initialize(attributes)
    super(attributes)
    post_initialize(attributes)
  end

  def pre_initialize(attributes= {})

  end

  def post_initialize(attributes= {})
  end

  # need hash like accessor, used internal Rails
  def [](attr)
    self.send(attr)
  end

  # need hash like accessor, used internal Rails
  def []=(attr, value)
    self.send("#{attr}=", value)
  end

end