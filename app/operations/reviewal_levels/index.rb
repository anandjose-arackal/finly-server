class ReviewalLevels::Index < ReviewalLevels::Base
  attr_accessor :reviewal_levels

  class ReviewalLevels::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :reviewal_levels, :levels

    has_scope :filter_policy
    has_scope :filter_policy_id
    has_scope :filter_policy_ids, type: :array
    has_scope :filter_associated_entity_type
    # has_scope :reviewal_level_id

    def init
      self.reviewal_levels = params[:reviewal_levels]

      if self.reviewal_levels.present?
        self.reviewal_levels = apply_scopes(self.reviewal_levels, params)
        self.reviewal_levels = self.reviewal_levels.non_deleted
        self.reviewal_levels = self.reviewal_levels.order(:level_number)
      end

      self.levels = self.reviewal_levels

    end
  end


  def init
    # policy_id = params[:filter_policy]
    # policy = user.company.policies.find_by(id: policy_id)
    # self.reviewal_levels = policy.levels.non_deleted

    policy_ids = user.company.policies.non_deleted.pluck(:id)
    self.reviewal_levels = ReviewalLevel.with_policy_ids(policy_ids)

  end

  # def validate
  #   # Currently implementing for vendor payments only
  #   if ['PurchaseOrderProvider', 'PurchaseRequestProvider', 'PaymentTicketProvider', 'YesBankVendorProvider'].include?(params[:filter_associated_entity_type])
  #     unless user.vendor_payments_admin?
  #       raise_unauthorized_exception
  #     end
  #   end
  # end

  def success
    params[:reviewal_levels] = self.reviewal_levels
    ReviewalLevels::Index::IndexPresenter.new(user, params, messages)
  end
end