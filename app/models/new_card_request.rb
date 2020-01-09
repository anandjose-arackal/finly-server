# == Schema Information
#
# Table name: new_card_requests
#
#  id                 :integer          not null, primary key
#  company_id         :integer
#  requesting_user_id :integer
#  card_type_id       :integer
#  status_id          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#


class NewCardRequest < ApplicationRecord
  belongs_to :company, optional: true
  belongs_to :requesting_user, optional: true, class_name: "User"
  belongs_to :card_type, optional: true
  belongs_to :status, optional: true, class_name: "CardRequestStatus"
end
