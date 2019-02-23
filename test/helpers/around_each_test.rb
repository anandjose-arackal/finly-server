module AroundEachTest

  def self.included(base)
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  def before_setup
    super
    DatabaseCleaner.start
  end

  def after_teardown
    super
    DatabaseCleaner.clean
  end
end