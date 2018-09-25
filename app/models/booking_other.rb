# == Schema Information
#
# Table name: booking_others
#
#  id              :integer          not null, primary key
#  parent_id       :integer
#  parent_type     :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  booking_details :text(65535)
#  description     :text(65535)
#  cost_id         :integer
#  is_deleted      :boolean          default(FALSE)
#  booking_id      :integer
#

class BookingOther < ActiveRecord::Base
  include SoftDeletable

  # belongs_to :parent, polymorphic: true
  belongs_to :booking, inverse_of: :booking_other
  belongs_to :cost, class_name: 'Amount', dependent: :destroy

  def as_json(options={})
    {
        id: id,
        booking_details: booking_details,
        description: description,
        cost: cost
    }
  end
end
