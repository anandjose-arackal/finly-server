# == Schema Information
#
# Table name: booking_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BookingStatus < ActiveRecord::Base
  include Seedable

  def self.values
    [:request, :rejected, :option, :selected_for_booking, :unavailable, :processing, :confirmed, :cancelled]
  end

  def request?
    id == BookingStatus.id_for(:request)
  end

  def option?
    id ==  BookingStatus.id_for(:option)
  end

  def selected_for_booking?
    id == BookingStatus.id_for(:selected_for_booking)
  end

  def confirmed?
    id == BookingStatus.id_for(:confirmed)
  end

  def processing?
    id == BookingStatus.id_for(:processing)
  end

  def cancelled?
    id == BookingStatus.id_for(:cancelled)
  end

  def rejected?
    id == BookingStatus.id_for(:rejected)
  end

end
