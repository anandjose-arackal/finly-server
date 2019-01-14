class Disburse::UsersController < BaseControllers::PublicBase
  def create
    @result = User::CreateWoPassword.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def import
    import_op = Import::Disburse::Users.new(current_user, params)
    @result = import_op.run
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
