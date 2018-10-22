# == Schema Information
#
# Table name: company_pocket_templates
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  company_id          :integer
#  user_pocket_type_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class CompanyPocketTemplate < ActiveRecord::Base
  belongs_to :company
  belongs_to :user_pocket_type


  scope :with_id, -> (ids) { where id: ids }
  scope :with_user_pocket_type_id, -> (user_pocket_type_id) { where user_pocket_type_id: user_pocket_type_id }

  validates :name, presence: true
  validates :user_pocket_type, presence: true

end