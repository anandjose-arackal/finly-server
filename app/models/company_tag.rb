# == Schema Information
#
# Table name: company_tags
#
#  id         :integer          not null, primary key
#  company_id :integer          not null
#  name       :string(255)      not null
#  gl_code    :string(255)
#  active     :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class CompanyTag < ActiveRecord::Base
  belongs_to :company
end
