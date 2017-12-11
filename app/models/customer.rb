# == Schema Information
#
# Table name: customers
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  email              :string(255)
#  mobile_number      :string(255)
#  description        :text(65535)
#  company_id         :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  gstin              :string(255)
#  tin                :string(255)
#  pan                :string(255)
#  created_by_user_id :integer
#

class Customer < ActiveRecord::Base

  belongs_to :company
end
