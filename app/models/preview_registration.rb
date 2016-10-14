# == Schema Information
#
# Table name: preview_registrations
#
#  id           :integer          not null, primary key
#  email        :string(255)
#  company      :text(65535)
#  phone_number :string(255)
#  name         :text(65535)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#



class PreviewRegistration < ActiveRecord::Base


end
