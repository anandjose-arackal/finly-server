# == Schema Information
#
# Table name: money_request_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  order      :integer          default(1), not null
#





class MoneyRequestStatus < ActiveRecord::Base

  VALUES = {open: 1, processing: 2, retracted: 3, rejected: 4, approved: 5, credited: 6}

  ORDER = {open: 1, processing: 3, retracted: 2, rejected: 4, approved: 5, credited: 6}

  scope :with_name, ->(name) { where name: name}

  self.class.instance_eval do
    VALUES.each do |key, value|
      define_method "#{key}_id" do
        value
      end
    end
  end

  VALUES.each do |key, value|
    define_method "#{key}?" do
      self.id == value
    end
  end

  def self.id_for(status)
    VALUES[status]
  end

  def self.order_for(status)
    ORDER[status]
  end

  def self.order_for_id(id)
    ORDER[VALUES.key(id)]
  end

  def status_name
    self.name
  end

end
