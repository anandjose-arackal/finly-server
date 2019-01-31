class AdminUsers::BankTransfersController < ApplicationController
  before_action -> { finly_authorize! :admin }

  def get_status
    @result = Admin::BankTransfer::GetStatus.(current_user, params)
    @respond
  end

  def get_bulk_status
    @result = Admin::BankTransfer::GetBulkStatus.(current_user, params)
    # sending the link to the frontend so that they can download the results

    if @result.success?
      @response = {
          success: true,
          file_url: @result.file_url,
          messages: {
              error: [],
              failure: [],
              success: [],
              message: [],
              notice: []
          }
      }
      respond_to do |format|
        format.json {
          render json: @response.as_json
        }
      end
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end
end
