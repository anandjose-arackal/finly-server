class CompanyConfiguration < ActiveRecord::Base
  belongs_to :company

  # associating receipt with the particular expense
  has_attached_file :logo, styles: {large: "2160x2160>", normal: "1080x1080>", thumb: "500x500>"}

end
