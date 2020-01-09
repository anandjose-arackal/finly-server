# == Schema Information
#
# Table name: notify_users
#
#  id            :bigint           not null, primary key
#  user_id       :integer
#  company_id    :integer
#  document_id   :integer
#  document_type :string(255)
#  enabled       :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class NotifyUser < ApplicationRecord
  belongs_to :parent, optional: true, polymorphic: true
  belongs_to :company, optional: true
  belongs_to :user, optional: true

  def as_json
    {
      id: self.id,
      email: self&.user&.email,
      mobile_number: self&.user&.mobile_number,
      name: self&.user&.name
    }
  end
end
