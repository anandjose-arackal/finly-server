class UserAgreementTrack < ActiveRecord::Base
  belongs_to :agreement
  belongs_to :user

  scope :with_user, -> (user_id) { where user_id: user_id }
  scope :with_agreement, -> (agreement_id) { where agreement_id: agreement_id }
end