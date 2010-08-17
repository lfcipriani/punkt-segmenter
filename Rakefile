require 'rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*.rb']
  t.verbose = true
end

desc "Run test coverage (need cover_me gem)"
task :coverage do
  ENV["coverage"] = "true"
  Rake::Task["test"].invoke
end

task :default => :test