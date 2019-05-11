class MinitestSetup
  def self.run(klass)
    Dir.glob("#{Rails.root}/test/helpers/**/*.rb").each {|r| require r}
    require 'mocha/minitest'
    klass.include FactoryBot::Syntax::Methods, AroundEachTest
  end
end