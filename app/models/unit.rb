# == Schema Information
#
# Table name: units
#
#  id         :bigint           not null, primary key
#  name       :string(255)      default("")
#  value      :string(255)      default("")
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Unit < ApplicationRecord
  Units = [
    {value:"BOU", name: 'BOU'},
    {value:"BGS", name: 'Bags'},
    {value:"BAL", name: 'Bale'},
    {value:"BTL", name: 'Bottles'},
    {value:"BOX", name: 'Boxes'},
    {value:"BKL", name: 'Buckles'},
    {value:"BUN", name: 'Bunches'},
    {value:"BDL", name: 'Bundles'},
    {value:"CAN", name: 'Cans'},
    {value:"CART", name: 'Carat'},
    {value:"CTN", name: 'Cartons'},
    {value:"CMS", name: 'Centimeter'},
    {value:"CCM", name: 'Cubic Centimeter'},
    {value:"CBM", name: 'Cubic Meter'},
    {value:"DOZ", name: 'Dozen'},
    {value:"DRM", name: 'Drums'},
    {value:"GMS", name: 'Grams'},
    {value:"GGK", name: 'Great Gross'},
    {value:"GRS", name: 'Gross'},
    {value:"GYD", name: 'Gross Yards'},
    {value:"KGS", name: 'Kilograms'},
    {value:"KLR", name: 'Kiloliter'},
    {value:"KME", name: 'Kilometers'},
    {value:"MTR", name: 'Meter'},
    {value:"MTS", name: 'Metric Ton'},
    {value:"MLT", name: 'Milliliters'},
    {value:"NOS", name: 'Numbers'},
    {value:"OTH", name: 'Others'},
    {value:"PAC", name: 'Packs'},
    {value:"PRS", name: 'Pairs'},
    {value:"PCS", name: 'Pieces'},
    {value:"QTL", name: 'Quintal'},
    {value:"ROL", name: 'Rolls'},
    {value:"SET", name: 'Sets'},
    {value:"SQF", name: 'Square Feet'},
    {value:"SQM", name: 'Square Meter'},
    {value:"SQY", name: 'Square Yards'},
    {value:"TBS", name: 'Tablets'},
    {value:"TGM", name: 'Ten Grams'},
    {value:"THD", name: 'Thousands'},
    {value:"TON", name: 'Tonnes'},
    {value:"TUB", name: 'Tubes'},
    {value:"UGS", name: 'US Gallons'},
    {value:"UNT", name: 'Units'},
    {value:"YDS", name: 'Yards'},
    {value:"QTR", name: 'Quarter'}
  ]

  def self.seed_data
    Units.each do |unit|
      next if Unit.find_by(value: unit[:value]).present?

      Unit.create(name: unit[:name], value: unit[:value])
    end
  end
end
