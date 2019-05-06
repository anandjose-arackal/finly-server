class AdminUsers::CardsController < BaseControllers::AdminBase

  # todo - temporary


  def create
    @result = Admin::Cards::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update
    @result = Admin::Cards::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def block
    if params[:card][:active] == '0'
      @result = Admin::Cards::Block.(current_user, params)
    elsif params[:card][:active] == '1'
      @result = Admin::Cards::Unblock.(current_user, params)
    end
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def show

  end

  # probably not required
  def destroy

  end

  def import
    @result = Admin::Cards::Import.(current_user, params)
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

  def bulk_assign
    @result = Admin::Cards::BulkAssign.(current_user, params)
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