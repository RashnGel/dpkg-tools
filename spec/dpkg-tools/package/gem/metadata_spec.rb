require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Gem::Metadata, "creating instances" do
  it "should be supplied a DpkgTools::Package::Gem::Data and a DpkgTools::Package::Config" do
    metadata = DpkgTools::Package::Gem::Metadata.new(:gem_data, :config)
    
    metadata.should be_an_instance_of(DpkgTools::Package::Gem::Metadata)
    metadata.send(:data).should == :gem_data
    metadata.send(:config).should == :config
  end
  
  it "should provide access to the path of the debian dir from #config" do
    stub_config = stub('DpkgTools::Package::Config', :debian_path => '/a/path')
    metadata = DpkgTools::Package::Gem::Metadata.new(:gem_data, stub_config)
    
    metadata.debian_path.should == '/a/path'
  end
  
  it "should provide access to the path of the rakefile from #config" do
    stub_data = stub('DpkgTools::Package::Gem::Data', :rakefile_path => '/a/path')
    metadata = DpkgTools::Package::Gem::Metadata.new(stub_data, :config)
    
    metadata.rakefile_path.should == '/a/path'
  end
end
