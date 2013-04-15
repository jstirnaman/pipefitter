require 'spec_helper'

describe Ditare::MarcRecordset do
  
  context "with OCLC recordset from SRU" do
    before do
      @mr_obj = Ditare::MarcRecordset.new(:oclc, {:q => 'AccessMedicine'})
    end
     
		describe "recordset" do 
			it "should be XML" do
			  @mr_obj.recordset.should be_a_kind_of Nokogiri::XML::Document
			end
		end
	
		describe "#read" do
			it "parses MARC records within a recordset" do
				@mr_obj.read do |rec|
					rec['title'].should_not be_nil
				end
			end
		end
		
		describe "#proxieds" do
		  it "returns arrays of marc record and proxy match" do
		    @mr_obj.proxieds.first[0].should be_kind_of String
		    @mr_obj.proxieds.first[1][0].should be_kind_of Mechanize::Page::Link
		  end
		end
		
		describe "#proxied" do
		  it "returns a set of MARC records with new 856s" do
		    @mr_obj.proxied.should be_kind_of Array
		    @mr_obj.proxied.first.should be_kind_of MARC::Record
		  end
		end
		
		describe "#tagged" do
		  it "returns a set of MARC records with tags added" do
		    @mr_obj.tagged.should be_kind_of Array
		    @mr_obj.tagged.first.should be_kind_of MARC::Record
		  end
		end
  end
end