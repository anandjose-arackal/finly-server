class ExportController < ApplicationController
  include MathUtil

  before_action :set_headers
  # before_action :authenticate_user!
  allow_oauth!

  def report
    respond_to do |format|
      format.csv {
        @report = Export::Report::AsCsv.(@user, params)
        send_data @report.data, filename: "#{@report.report_names}.csv"
      }
      format.xls {
        @report = Export::Report::AsXml.(@user, params)
        @header = @report.header
        @data = @report.data
      }
      format.pdf {
        @result = Report::Show.(@user, params)
        @report = @result.report
        @current_user = current_user
        @include_comments = true
        render pdf: "report-#{@report.name}", layout: "pdf.html.erb", print_media_type: true
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
