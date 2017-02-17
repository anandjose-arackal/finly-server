class FakeFileIO < StringIO
  attr_reader :original_filename
  attr_reader :path
  attr_reader :content_type

  def initialize(filename, content, content_type = nil)
    super(content)
    @original_filename = File.basename(filename)
    @path = File.path(filename)
    @content_type = content_type
  end
end
