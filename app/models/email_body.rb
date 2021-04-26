# == Schema Information
#
# Table name: email_bodies
#
#  id         :bigint           not null, primary key
#  company_id :integer
#  email_id   :integer          not null
#  body       :text(4294967295)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class EmailBody < ApplicationRecord
  belongs_to :email
  belongs_to :company, optional: true
end
