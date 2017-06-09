class File::Download < BaseHandler

  attr_accessor :file

  class File::Download::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :file, :file_name

    def init
      self.file = params[:file]
    end

  end

  def pre_validate
    if params.blank? || params[:url].blank?
      add_message :error, 'URL not found'
      return
    end
    if params[:file_name].blank?
      add_message :error, 'File name cannot be blank'
    end
  end

  def path
    params[:url]
  end

  def parse
    self.file = FakeFileIO.new(params[:file_name], self.response.body)
  end

  def success
    params[:file] = self.file
    File::Download::SuccessPresenter.new(user, params, messages)
  end

end