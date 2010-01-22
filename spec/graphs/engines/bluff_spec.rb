require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "Bluff graphers responding to #graph!" do
  it "should write chart file" do
    MetricFu.configuration
    graphs = {}
    MetricFu::AVAILABLE_GRAPHS.each do |graph|
      graphs[graph] = MetricFu.const_get("#{graph.to_s.capitalize}BluffGrapher").new
    end
    graphs.each do |key, val|
      val.graph!
      lambda{ File.open(File.join(MetricFu.output_directory, "#{key.to_s.downcase}.js")) }.should_not raise_error
    end
  end
end