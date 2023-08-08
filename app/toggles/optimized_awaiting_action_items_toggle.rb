class OptimizedAwaitingActionItemsToggle < ApplicationToggle
  def enabled?
    feature_flag 'feature/optimized_awaiting_action_items', false
  end
end
