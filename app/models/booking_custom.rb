# == Schema Information
#
# Table name: booking_customs
#
#  id                  :integer          not null, primary key
#  journey_date        :date
#  journey_destination :string(255)
#  journey_source      :string(255)
#  parent_id           :integer
#  parent_type         :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class BookingCustom < ActiveRecord::Base

  belongs_to :parent, polymorphic: true

end
