$LOAD_PATH << '.'
require 'rake'
require 'rake/rdoctask'
require 'spec/rake/spectask'
require 'lib/metric_fu'
 
desc "Run all specs in spec directory"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end
 
MetricFu::Configuration.run do |config|
  config.roodi = config.roodi.merge(:roodi_config => 'config/roodi_config.yml')
end
 
task :default => :spec
