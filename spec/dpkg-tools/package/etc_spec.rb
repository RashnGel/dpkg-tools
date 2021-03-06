require File.dirname(__FILE__) + '/../../spec_helper'

describe DpkgTools::Package::Etc, ".create_builder" do
  it "should instantiate a Package::Etc::Data and a Package::Etc::Builder and make 'em work" do
    DpkgTools::Package::Etc::Builder.expects(:from_path).with('/path/to/package').returns(:builder)
    
    DpkgTools::Package::Etc.create_builder('/path/to/package').should == :builder
  end
end

describe DpkgTools::Package::Etc, ".setup_from_path" do
  it "should be able to create package structure from a path to a not-yet-extant conf package dir" do
    mock_setup = mock('mock DpkgTools::Package::Etc::Setup')
    File.stubs(:directory?).with('/path/to/package').returns(false)
    Dir.expects(:mkdir).with('/path/to/package')
    DpkgTools::Package::Etc::Setup.expects(:from_path).with('/path/to/package').returns(mock_setup)
    mock_setup.expects(:create_structure)
    
    DpkgTools::Package::Etc.setup_from_path('/path/to/package')
  end
  
  it "should be able to create package structure from a path to a dir that exists" do
    mock_setup = mock('mock DpkgTools::Package::Etc::Setup')
    File.stubs(:directory?).with('/path/to/package').returns(true)
    Dir.expects(:mkdir).with('/path/to/package').never
    DpkgTools::Package::Etc::Setup.expects(:from_path).with('/path/to/package').returns(mock_setup)
    mock_setup.expects(:create_structure)
    
    DpkgTools::Package::Etc.setup_from_path('/path/to/package')
  end
end

describe DpkgTools::Package::Etc, ".create_setup" do
  it "should be able to create a Setup instance" do
    DpkgTools::Package::Etc::Setup.expects(:from_path).with('/path/to/package').returns(:setup)
    
    DpkgTools::Package::Etc.create_setup('/path/to/package').should == :setup
  end
end
