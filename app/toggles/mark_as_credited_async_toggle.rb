# release/mark_as_credited_async
class MarkAsCreditedAsyncToggle < ApplicationToggle

  def enabled?
    feature_flag 'release/mark_as_credited_async', false
  end

end

