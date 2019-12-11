# == Schema Information
#
# Table name: gatekeeper_blocks
#
#  id            :bigint           not null, primary key
#  user_id       :integer
#  company_id    :integer
#  params        :text(65535)
#  headers       :text(65535)
#  act           :string(255)
#  premise       :string(255)
#  verdict       :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  rule          :string(255)
#  level         :integer          default(1), not null
#  admin_user_id :integer
#

class GatekeeperBlock < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :company, optional: true
  belongs_to :admin_user, optional: true

  validates :act, presence: true
  validates :premise, presence: true
  validates :rule, presence: true
  validates :verdict, presence: true
end
