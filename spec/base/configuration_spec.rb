require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe MetricFu::Configuration do
    
  def get_new_config
    @config = Configuration.new
  end
  
  def base_directory
    @config.instance_variable_get(:@base_directory)
  end

  def output_directory
    @config.instance_variable_get(:@output_directory)
  end

  def scratch_directory
    @config.instance_variable_get(:@scratch_directory)
  end

  def template_directory
    @config.instance_variable_get(:@template_directory)
  end

  def template_class
    @config.instance_variable_get(:@template_class)
  end

  def metric_fu_root
    @config.instance_variable_get(:@metric_fu_root_directory)
  end

  describe '#warn_about_deprecated_config_options' do

    def get_new_config_and_raise_runtime_error
      lambda { get_new_config  }.should raise_error
    end

    describe 'when ::MetricFu::CHURN_OPTIONS is present' do
      before(:each) { ::MetricFu::CHURN_OPTIONS = 'option' }
      after(:each)  { ::MetricFu.send(:remove_const, 'CHURN_OPTIONS') }
      
      it 'should raise a RuntimeError with "Use config.churn '+ 
      'instead of MetricFu::CHURN_OPTIONS"' do
        get_new_config_and_raise_runtime_error
      end
    end
    
    describe 'when ::MetricFu::DIRECTORIES_TO_FLOG is present' do
      before(:each) { ::MetricFu::DIRECTORIES_TO_FLOG = 'option' }
      after(:each)  { ::MetricFu.send(:remove_const,'DIRECTORIES_TO_FLOG')}

      it 'should raise a RuntimeError with "Use config.flog '+
      '[:dirs_to_flog] instead of MetricFu::DIRECTORIES_TO_FLOG' do
        get_new_config_and_raise_runtime_error
      end 
    end

    describe 'when ::MetricFu::SAIKURO_OPTIONS is present' do
      before(:each) { ::MetricFu::SAIKURO_OPTIONS = 'option' }
      after(:each)  { ::MetricFu.send(:remove_const,'SAIKURO_OPTIONS')}
      
      it 'should raise a RuntimeError with "Use config.saikuro '+
      'instead of MetricFu::SAIKURO_OPTIONS' do 
        get_new_config_and_raise_runtime_error
      end
    end

    describe 'when SAIKURO_OPTIONS is present' do
      before(:each) { SAIKURO_OPTIONS = 'option' }
      after(:each)  { Object.send(:remove_const,'SAIKURO_OPTIONS')}
      
      it 'should raise a RuntimeError with "Use config.saikuro '+
      'instead of SAIKURO_OPTIONS' do
        get_new_config_and_raise_runtime_error
      end
    end
  end

  describe "#reset" do
    
    before(:each) { get_new_config } 
    
    describe 'when there is a CC_BUILD_ARTIFACTS environment variable' do
      before(:each) { ENV['CC_BUILD_ARTIFACTS'] = 'foo' } 
   
      it 'should return the CC_BUILD_ARTIFACTS environment variable' do
        get_new_config
        base_directory.should == ENV['CC_BUILD_ARTIFACTS']
      end
    end

    describe 'when there is no CC_BUILD_ARTIFACTS environment variable' do
      before(:each) { ENV['CC_BUILD_ARTIFACTS'] = nil  }
      
      it 'should return "tmp/metric_fu"' do
        get_new_config
        base_directory.should == "tmp/metric_fu"
      end
    end
    
    it 'should set @metric_fu_root_directory to the base of the '+
    'metric_fu application' do
      app_root = File.join(File.dirname(__FILE__), '..', '..')
      app_root_absolute_path = File.expand_path(app_root)
      metric_fu_absolute_path = File.expand_path(metric_fu_root)
      metric_fu_absolute_path.should == app_root_absolute_path 
    end

    it 'should set @template_directory to the lib/templates relative '+
    'to @metric_fu_root_directory' do
      template_dir = File.join(File.dirname(__FILE__), 
                               '..', '..', 'lib','templates')
      template_dir_abs_path = File.expand_path(template_dir)
      calc_template_dir_abs_path = File.expand_path(template_directory)
      calc_template_dir_abs_path.should == template_dir_abs_path
    end
    
    it 'should set @scratch_directory to scratch relative '+
    'to @base_directory' do
      scratch_dir = File.join(base_directory, 'scratch')
      scratch_directory.should == scratch_dir
    end

    it 'should set @output_directory to output relative '+
    'to @base_directory' do
      output_dir = File.join(base_directory, 'output')
      output_directory.should == output_dir
    end
    
    it 'should set @template_class to StandardTemplate' do
      template_class.should == AwesomeTemplate
    end

    it 'should set @flay to {:dirs_to_flay => @code_dirs}' do
      @config.instance_variable_get(:@flay).
              should == {:dirs_to_flay => ['lib']}
    end
    
    it 'should set @flog to {:dirs_to_flog => @code_dirs}' do
      @config.instance_variable_get(:@flog).
              should == {:dirs_to_flog => ['lib']}
    end
    
    it 'should set @reek to {:dirs_to_reek => @code_dirs}' do
      @config.instance_variable_get(:@reek).
              should == {:dirs_to_reek => ['lib']}
    end

    it 'should set @roodi to {:dirs_to_roodi => @code_dirs}' do
      @config.instance_variable_get(:@roodi).
              should == {:dirs_to_roodi => ['lib']}
    end
   
    it 'should set @churn to {}' do
      @config.instance_variable_get(:@churn).
              should == {}
    end

    it 'should set @stats to {}' do
      @config.instance_variable_get(:@stats).
              should == {}
    end

    it 'should set @rcov to { :test_files => ["test/**/*_test.rb", 
                                              "spec/**/*_spec.rb"] 
                              :rcov_opts  => ["--sort coverage",   
                                              "--no-html",         
                                              "--text-coverage",   
                                              "--no-color",        
                                              "--profile",         
                                              "--rails",           
                                              "--exclude /gems/,/Library/,/usr/,spec"]}' do
      @config.instance_variable_get(:@rcov).
              should ==  { :test_files => ['test/**/*_test.rb', 
                                           'spec/**/*_spec.rb'],
                           :rcov_opts => ["--sort coverage", 
                                         "--no-html", 
                                         "--text-coverage",
                                         "--no-color",
                                         "--profile",
                                         "--rails",
                                         "--exclude /gems/,/Library/,/usr/,spec"]}
    end

    it 'should set @saikuro to { :output_directory => @scratch_directory + "/saikuro",
                                 :input_directory => @code_dirs,
                                 :cyclo => "",
                                 :filter_cyclo => "0",
                                 :warn_cyclo => "5",
                                 :error_cyclo => "7",
                                 :formater => "text" }' do
      @config.instance_variable_get(:@saikuro).
              should ==  { :output_directory => 'tmp/metric_fu/scratch/saikuro', 
                    :input_directory => ['lib'],
                    :cyclo => "",
                    :filter_cyclo => "0",
                    :warn_cyclo => "5",
                    :error_cyclo => "7",
                    :formater => "text"}
    end

    describe 'if #rails? is true ' do
      before(:each) do
        @config.stub!(:rails?).and_return(true)
      end

      describe '#set_metrics ' do
        it 'should set the @metrics instance var to AVAILABLE_METRICS + '\
           +'[:stats]' do
          @config.instance_variable_get(:@metrics).
                  should == MetricFu::AVAILABLE_METRICS << [:stats]
        end
      end

      describe '#set_code_dirs ' do
        it 'should set the @code_dirs instance var to ["app", "lib"]' do
          # This is hard to spec properly because the @code_dirs variable
          # is set during the reset process.
          #@config.instance_variable_get(:@code_dirs).
          #        should == ['app','lib']
        end
      end
    end

    describe 'if #rails? is false ' do
      before(:each) do
        @config.stub!(:rails?).and_return(false)
      end
     
      describe '#set_metrics ' do
        it 'should set the @metrics instance var to AVAILABLE_METRICS' do
          @config.instance_variable_get(:@metrics).
                  should == MetricFu::AVAILABLE_METRICS
        end
      end

      describe '#set_code_dirs ' do
        it 'should set the @code_dirs instance var to ["lib"]' do
          @config.instance_variable_get(:@code_dirs).should == ['lib']
        end
      end
    end
  end

  describe '#add_attr_accessors_to_self' do
    
    before(:each) { get_new_config } 
  
    MetricFu::AVAILABLE_METRICS.each do |metric|
      it "should have a reader for #{metric}" do
        @config.respond_to?(metric).should be_true
      end

      it "should have a writer for #{metric}=" do
        @config.respond_to?((metric.to_s + '=').to_sym).should be_true
      end
    end
  end

  describe '#add_class_methods_to_metric_fu' do
  
    before(:each) { get_new_config }

    MetricFu::AVAILABLE_METRICS.each do |metric|
      it "should add a #{metric} class method to the MetricFu module " do
        MetricFu.respond_to?(metric).should be_true
      end
    end
  end

  describe '#platform' do

    before(:each) { get_new_config }

    it 'should return the value of the PLATFORM constant' do
      this_platform = PLATFORM
      @config.platform.should == this_platform
    end
  end

  describe '#is_cruise_control_rb? ' do

    before(:each) { get_new_config }
    describe "when the CC_BUILD_ARTIFACTS env var is not nil" do

      before(:each) { ENV['CC_BUILD_ARTIFACTS'] = 'is set' }

      it 'should return true'  do
        @config.is_cruise_control_rb?.should be_true
      end

    end

    describe "when the CC_BUILD_ARTIFACTS env var is nil" do
      before(:each) { ENV['CC_BUILD_ARTIFACTS'] = nil }
     
      it 'should return false' do
        @config.is_cruise_control_rb?.should be_false
      end
    end
  end
end
