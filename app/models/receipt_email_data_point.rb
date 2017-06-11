# == Schema Information
#
# Table name: receipt_email_data_points
#
#  id                        :integer          not null, primary key
#  amount_xpath              :text(65535)
#  amount_xpath_regex        :string(255)
#  amount_css_selector       :text(65535)
#  amount_css_selector_regex :string(255)
#  receipt_email_template_id :integer          not null
#  priority                  :decimal(10, )    default(0), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  amount_mode_id            :integer          not null
#

class ReceiptEmailDataPoint < ActiveRecord::Base
  belongs_to :amount_mode, class_name: 'ReceiptEmailDataPointMode'
  belongs_to :receipt_email_template

  # serialize :amount_xpath_regex, Regexp
  # serialize :amount_css_selector_regex, Regexp

  validates :amount_mode, presence: true
  validates :receipt_email_template_id, presence: true

  default_scope { order priority: :desc }

  def xpath_only_mode?(type)
    case type
      when :amount
        return amount_mode.xpath_only?
    end
  end

  def css_selector_only_mode?(type)
    case type
      when :amount
        return amount_mode.css_selector_only?
    end
  end

  def xpath_first_mode?(type)
    case type
      when :amount
        return amount_mode.xpath_first?
    end
  end

  def css_selector_first_mode?(type)
    case type
      when :amount
        return amount_mode.css_selector_first?
    end
  end

end
