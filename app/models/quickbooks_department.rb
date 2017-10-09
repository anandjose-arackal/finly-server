# == Schema Information
#
# Table name: quickbooks_departments
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  quickbooks_id          :integer
#  active                 :boolean
#  company_id             :integer
#  additional_information :text(65535)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class QuickbooksDepartment < ActiveRecord::Base

  belongs_to :company

  scope :with_name, -> (name) {where name: name}
end
