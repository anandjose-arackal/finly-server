# == Schema Information
#
# Table name: gatekeeper_blocks
#
#  id         :bigint(8)        not null, primary key
#  user_id    :integer
#  company_id :integer
#  params     :text(65535)
#  headers    :text(65535)
#  act        :string(255)
#  premise    :string(255)
#  rule       :string(255)
#  violation  :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class GatekeeperBlock < ApplicationRecord
  belongs_to :user
  belongs_to :company

  validates :act, presence: true
  validates :premise, presence: true
  validates :rule, presence: true
  validates :verdict, presence: true
end
