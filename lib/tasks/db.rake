namespace :db do
  desc "Does db drop -> create -> migrate -> seed"
  task vivekify: :environment do
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:seed"].invoke
  end
end
