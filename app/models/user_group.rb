# == Schema Information
#
# Table name: user_groups
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  company_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  is_deleted :boolean          default(FALSE)
#

class UserGroup < ActiveRecord::Base
  include SoftDeletable

  belongs_to :company
  has_many :user_group_items

  accepts_nested_attributes_for :user_group_items

  validates :name, uniqueness: {scope: :company_id, :case_sensitive => false}

  scope :include_items, -> { includes(:user_group_items) }
end
