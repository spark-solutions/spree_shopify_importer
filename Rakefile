require "bundler"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
require "spree/testing_support/extension_rake"

RSpec::Core::RakeTask.new

task :default do
  if Dir["spec/dummy"].empty?
    Rake::Task[:test_app].invoke
    Dir.chdir("../../")
  end
  require "rubocop/rake_task"
  RuboCop::RakeTask.new
  Rake::Task["rubocop"].invoke
  Rake::Task[:spec].invoke
end

desc "Generates a dummy app for testing"
task :test_app do
  ENV["LIB_NAME"] = "spree_shopify_importer"
  Rake::Task["extension:test_app"].invoke
end
