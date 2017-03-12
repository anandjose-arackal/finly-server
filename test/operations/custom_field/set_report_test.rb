require 'test_helper'

require 'minitest/unit'
require 'mocha/mini_test'

class SetReportTest < ActiveSupport::TestCase

  def setup
    @report = Report.first
  end

end