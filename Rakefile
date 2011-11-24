require "bundler/gem_tasks"

task :default => :spec

require "rake/testtask"
Rake::TestTask.new(:spec) do |task|
  task.test_files = FileList['spec/**/*_spec.rb']
end
