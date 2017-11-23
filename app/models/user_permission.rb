# == Schema Information
#
# Table name: user_permissions
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  company_id           :integer
#  create_beneficiaries :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class UserPermission < ActiveRecord::Base
  belongs_to :user
  belongs_to :company

end
