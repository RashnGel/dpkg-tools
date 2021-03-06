require File.dirname(__FILE__) + '/../../../../spec_helper'

describe DpkgTools::Package::Gem::ControlFiles::Changelog, "#changelog" do
  before(:each) do
    config = DpkgTools::Package::Config.new('gem-name', '1.0.8', :suffix => 'rubygem')
    stub_data = stub('DpkgTools::Package::Gem::Data', :full_name => 'gem-name-1.0.8', :debian_revision => '1')
    @metadata = DpkgTools::Package::Gem::ControlFiles::Changelog.new(stub_data, config)
  end
  
  it "should be able to generate the current time formatted as per RFC 822" do
    mock_time = mock('Time')
    mock_time.expects(:rfc822).returns('rfc_time')
    Time.expects(:now).returns(mock_time)
    
    @metadata.change_time.should == 'rfc_time'
  end
  
  it "should be able to generate a changelog" do
    @metadata.expects(:change_time).returns('RFC 822 change time')
    
    @metadata.changelog.should == "gem-name-rubygem (1.0.8-1) cp-gutsy; urgency=low\n"\
    "  * Packaged up gem-name-1.0.8\n"\
    " -- Matt Patterson <matt@reprocessed.org>  RFC 822 change time\n"
  end
end
