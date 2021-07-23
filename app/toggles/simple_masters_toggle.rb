class SimpleMastersToggle < ApplicationToggle
  def simple_masters_enabled?
    feature_flag 'release/simple_masters#simple_masters_enabled', false
  end
end
