class ExportController < ApplicationController
  include MathUtil

  before_action :set_headers
  # before_action :authenticate_user!
  allow_oauth!

  def report
    # debugger
    respond_to do |format|
      format.csv {
        @report = Export::Report::AsCsv.(@user, params)
        send_data @report.data
      }
      format.xls {
        @report = Export::Report::AsXml.(@user, params)
        @header = @report.header
        @data = @report.data
      }
      format.pdf {
        @report = Report::Show.new(@user, params).run
        render pdf: "report-#{@report.report.name}", layout: "pdf.html.erb"
      }
    end
  end

  def statement
    respond_to do |format|
      format.csv {
        @employee_statement = Export::CardStatement::AsCsv.(@user, params)
        send_data @employee_statement.data
      }
      format.xls {
        @employee_statement = Export::CardStatement::AsXls.(@user, params)
        @header = @employee_statement.header
        @data = @employee_statement.data
      }
      format.pdf {
        # todo - need to create view for this
      }
    end
  end

  private

  def set_headers

    access_token = request.cookies["access_token"]
    query = "SELECT `id`, `user_id`, `access_token_expires_at` FROM `opro_auth_grants` WHERE `access_token`='" + access_token + "' LIMIT 1"
    results = ActiveRecord::Base.connection.execute(query)

    user_id = nil
    expires_at = nil

    if results.count == 1
      results.each do |row|
        user_id = row[1]
        expires_at = row[2]
      end

      if Time.now < expires_at
        # Token is valid
        @user = User.find(user_id)
      else
        # Token has expired
        @user = false
      end

    else
      # NOT AUTHORIZED
      @user = false
    end

    unless @user
      render json: {success: false, message: "Please login."}
    end

  end
end
