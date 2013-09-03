require 'spec_helper'

describe Ezproxy::Client do
  
  context "with Ezproxy client" do
    before do
      @client = Ezproxy::Client.new
      @query = /Pub/
    end
        
		describe "#links" do 
		  it "returns an array of Mechanize link objects" do
			  @client.links({:text => @query}).should be_kind_of Array 
			  @client.links({:text => @query}).first.should be_kind_of Mechanize::Page::Link
			end 
		end
		
		describe "#links_to_hash" do
		  it "returns an array of link hashes converted from Mechanize objects" do
		    linkscoll = @client.links_to_hash({:text => @query})
		    linkscoll.should be_kind_of Array
		    linkscoll.first.should be_kind_of Hash
        linkscoll.first.keys.should include(:text)
      end
    end
    
    describe "#get_marc" do
      it "returns a hash of marc record hashes that match Proxied links" do
        @client.get_marc({:text => @query}).should be_kind_of Array
      end
    end
	end
  
end