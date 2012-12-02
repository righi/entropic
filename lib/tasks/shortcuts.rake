namespace :sc do

  desc "Drop all databases, run migrations, and prepare test db"
  task :rebuild => :environment do
    Rake::Task['db:drop:all'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:test:prepare'].invoke
  end
  
end
