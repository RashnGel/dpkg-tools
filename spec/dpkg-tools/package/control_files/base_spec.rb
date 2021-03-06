require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::ControlFiles::Base, "writing control files out" do
  it "should be able to make the target dir" do
    Dir.expects(:mkdir).with('a_path/debian')
    File.stubs(:exists?).with('a_path/debian').returns(false)

    DpkgTools::Package::ControlFiles::Base.check_target_dir("a_path/debian")
  end

  it "should be able to write a file in the debian dir" do
    DpkgTools::Package::ControlFiles::Base.expects(:check_target_dir).with('a_path/debian')
    mock_file = mock('Mock file')
    mock_file.expects(:write).with('file contents')
    File.expects(:open).with('a_path/debian/filename', 'w').yields(mock_file)

    DpkgTools::Package::ControlFiles::Base.write('a_path/debian/filename', 'file contents')
  end

  it "should be able to write an executable file in the debian dir" do
    DpkgTools::Package::ControlFiles::Base.expects(:write).with('a_path/debian/rules', 'file contents')
    File.expects(:chmod).with(0755, "a_path/debian/rules")
    DpkgTools::Package::ControlFiles::Base.write_executable('a_path/debian/rules', 'file contents')
  end
  
  it "should be able to return its filename" do
    DpkgTools::Package::ControlFiles::Base.filename.should == 'base'
  end
  
  it "should be able to return its formatter class" do
    DpkgTools::Package::ControlFiles::Base.formatter_class.should == DpkgTools::Package::ControlFiles::BaseFormatter
  end
end

describe DpkgTools::Package::ControlFiles::Base, "creating instances" do
  it "should require a data and config object to be passed in" do
    DpkgTools::Package::ControlFiles::Base.new(:data, :config).should be_an_instance_of(DpkgTools::Package::ControlFiles::Base)
  end
  
  it "should fail if no arguments are passed in" do
    lambda { DpkgTools::Package::ControlFiles::Base.new }.should raise_error
  end
  
  it "should fail if only one argument is passed in" do
    lambda { DpkgTools::Package::ControlFiles::Base.new(:data) }.should raise_error
  end
end

describe DpkgTools::Package::ControlFiles::Base, "instances" do
  before(:each) do
    @config = DpkgTools::Package::Config.new('name', '1.0', :base_path => '/a/path/to/package')
    @formatter = mock('DpkgTools::Package::ControlFiles::BaseFormatter')
    DpkgTools::Package::ControlFiles::BaseFormatter.expects(:new).with(anything).returns(@formatter)
    @control_file = DpkgTools::Package::ControlFiles::Base.new(:data, @config)
  end
  
  it "should use the class' value for filename" do
    DpkgTools::Package::ControlFiles::Base.expects(:filename).returns(:class_filename)
    @control_file.filename.should == :class_filename
  end
  
  it "should be able to return its formatter class instance" do
    @control_file.formatter.should == @formatter
  end
  
  it "should be able to figure out where it should be written" do
    @control_file.file_path.should == '/a/path/to/package/debian/base'
  end
  
  it "should be able to specify whether to write itself out as an executable" do
    @control_file.executable?.should be_false
  end
  
  it "should be able to write itself out" do
    @control_file.expects(:to_s).returns('file contents')
    DpkgTools::Package::ControlFiles::Base.expects(:write).with('/a/path/to/package/debian/base', 'file contents')
    
    @control_file.write
  end
  
  it "should be able to create a string with the file contents in" do
    @formatter.expects(:build).returns('file contents')
    
    @control_file.to_s.should == 'file contents'
  end
  
  it "should be able to tell that the existing control file is different to the one that this instance would generate" do
    @control_file.expects(:to_s).returns('new file contents')
    @control_file.stubs(:file_path).returns('/a/path/to/control_file')
    File.expects(:exist?).with('/a/path/to/control_file').returns(true)
    File.expects(:read).with('/a/path/to/control_file').returns('file contents')
    
    @control_file.needs_reset?.should be_true
  end
  
  it "should be able to tell that the existing control file is the same as the one that this instance would generate" do
    @control_file.expects(:to_s).returns('file contents')
    @control_file.stubs(:file_path).returns('/a/path/to/control_file')
    File.expects(:exist?).with('/a/path/to/control_file').returns(true)
    File.expects(:read).with('/a/path/to/control_file').returns('file contents')
    
    @control_file.needs_reset?.should be_false
  end
  
  it "should know that if a control file is missing then a reset is needed by default" do
    @control_file.expects(:file_path).returns('/a/path/to/control_file')
    File.expects(:exist?).with('/a/path/to/control_file').returns(false)
    
    @control_file.needs_reset?.should be_true
  end
end