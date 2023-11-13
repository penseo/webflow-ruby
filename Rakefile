require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new(:test) do |t|
  ENV['TEST_API_TOKEN'] = 'your_api_token_here' if ENV['TEST_API_TOKEN'].nil?
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

RuboCop::RakeTask.new

task default: %i[rubocop test]
