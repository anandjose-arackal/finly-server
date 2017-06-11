# == Schema Information
#
# Table name: receipt_email_data_points
#
#  id                        :integer          not null, primary key
#  amount_xpath              :text(65535)      not null
#  amount_xpath_regex        :string(255)      not null
#  amount_css_selector       :text(65535)      not null
#  amount_css_selector_regex :string(255)      not null
#  mode_id                   :integer          not null
#  receipt_email_template_id :integer          not null
#  priority                  :decimal(10, )    default(0), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class ReceiptEmailDataPoint < ActiveRecord::Base
  belongs_to :mode, class_name: 'ReceiptEmailDataPointMode'
  belongs_to :receipt_email_template
end
