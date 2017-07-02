# == Schema Information
#
# Table name: login_agreement_mappings
#
#  id           :integer          not null, primary key
#  user_id      :integer          not null
#  agreement_id :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class LoginAgreementMapping < ActiveRecord::Base
  belongs_to :user
  belongs_to :agreement
end
