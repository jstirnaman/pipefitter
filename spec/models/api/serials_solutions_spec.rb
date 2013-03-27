require 'spec_helper'

describe SerialsSolutions::Openurl::Client do
  
  context "with SS OpenURL client" do
    before do
      @client = SerialsSolutions::Openurl::Client.new({:issn => '2218-2020'})
    end
        
		describe "OpenURL response" do 
			it "returns an OpenURL response" do
			  @client.openurl_response['version'].should eq "1.0"
			end  
		end
	end
  
end