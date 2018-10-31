class ReviewalLevels::Index < ReviewalLevels::Base
  attr_accessor :reviewal_levels

  class ReviewalLevels::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :reviewal_levels

    has_scope :filter_policy
    has_scope :filter_associated_entity_type

    def init
      self.reviewal_levels = params[:reviewal_levels]

      if self.reviewal_levels.present?
        self.reviewal_levels = apply_scopes(self.reviewal_levels, params)
        self.reviewal_levels = self.reviewal_levels.order(:level_number)
      end

    end
  end


  def init
    self.reviewal_levels = ReviewalLevel.all
  end

  def success
    params[:reviewal_levels] = self.reviewal_levels
    ReviewalLevels::Index::IndexPresenter.new(user, params, messages)
  end
end