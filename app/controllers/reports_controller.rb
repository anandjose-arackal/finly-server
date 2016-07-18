class ReportsController < ApplicationController

  def reports

  end

  def show_report

    @violations_found = true
    @status = "SUBMITTED"
  end

end
