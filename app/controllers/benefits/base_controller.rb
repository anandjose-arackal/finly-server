class Benefits::BaseController < BaseControllers::WebBase


  before_action -> { finly_authorize! :web}

  def process_file
    @result = Benefits::TaxBenefits::ParseFile.(config, current_user, params)
    respond
  end

  def create
    @result = Benefits::TaxBenefits::Create.(config, current_user, params)
    respond
  end

  def update
    @result = Benefits::TaxBenefits::Update.(config, current_user, params)
    if @result.success?
      respond_to do |format|
        format.json { render 'benefits/base/process_file' }
        format.html {}
      end
      return
    end
    respond
  end

  def index
    @result = Benefits::TaxBenefits::Index.(config, current_user, params)
    respond
  end

  def show
    @result = Benefits::TaxBenefits::Show.(config, current_user, params)
    respond
  end

  def destroy
    @result = Benefits::TaxBenefits::Cancel.(config, current_user, params)
    respond response: @result.success? ? :success : :failure
  end

  protected
  def config

  end

end
