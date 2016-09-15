class Operations

  # Monkey patching as per http://stackoverflow.com/questions/19098663/auto-loading-lib-files-in-rails-4
  Dir[File.expand_path "#{Rails.root}/lib/operations/event/**/*.rb"].each{|f| require(f)}

end