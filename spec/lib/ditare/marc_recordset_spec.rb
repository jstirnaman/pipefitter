require 'spec_helper'

describe Ditare::MarcRecordset do
  
  context "with OCLC recordset from SRU" do
    before do
      @mr_obj = Ditare::MarcRecordset.new(:oclc, {:q => 'accessmedicine'}) 
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
		
  end
end