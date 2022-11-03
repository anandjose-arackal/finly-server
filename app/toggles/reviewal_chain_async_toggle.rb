# release/reviewal_chain_async
class ReviewalChainAsyncToggle < ApplicationToggle

  def enabled?
    feature_flag 'release/reviewal_chain_async', false
  end

end
