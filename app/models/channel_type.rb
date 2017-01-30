# == Schema Information
#
# Table name: channel_types
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  abbreviation :string(255)
#

class ChannelType < ActiveRecord::Base

  TYPES = {atm: 1, pos: 2, ecom: 3}

  NAMES = { 1 => "ATM Withdrawal",
            2=> "Point of Sale (POS)",
            3 => "E-Commerce" }

end
