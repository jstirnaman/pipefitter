require 'spec_helper'

describe Ezproxy::Client do
  
  context "with Ezproxy client" do
    before do
      @client = Ezproxy::Client.new
    end
        
		describe "#links" do 
		  it "returns an array of Mechanize link objects" do
			  @client.links.should be_kind_of Array 
			  @client.links.first.should be_kind_of Mechanize::Page::Link
			end  
		end
	end
  
end