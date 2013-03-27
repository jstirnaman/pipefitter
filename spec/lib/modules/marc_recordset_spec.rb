require 'spec_helper'

describe MarcRecordset do
  
  context "with recordset from source" do
    before do
      @records = MarcRecordset.new(:oclc, {:q => 'accessmedicine'}) 
    end
     
		describe "recordset" do 
			it "returns an XML response from SRU" do
			  @records.recordsource.should be_a_kind_of Nokogiri::XML::Document
			end
		end
	
		describe "#read" do
			it "parses MARC records in a recordset" do
				@records.read do |rec|
					rec['title'].should_not be_nil
				end
			end
		end
  end
end