class ReviewalManager::Base < BaseOperation
  attr_accessor :next_reviewer, :chain_of_reviewers

  def init

  end
end