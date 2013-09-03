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
		    @mr_obj.proxied.first.should be_kind_of String
		  end
		end
		
		describe "#tagged" do
		  it "returns a set of MARC records with tags added" do
		    @mr_obj.tagged.should be_kind_of Array
		    @mr_obj.tagged.first.should be_kind_of String
		  end
		end
		
		describe "#enriched" do
		  it "returns a new MarcRecordset object with all enrichments added to the recordset" do
		    @mr_obj.enriched.should be_kind_of Ditare::MarcRecordset
		    @mr_obj.enriched.recordset.should be_kind_of String
		  end
		end
		
		describe "#to_marc_export" do
		  it "writes the records in recordset attribute to a MARC file" do
		     fh = @mr_obj.export_file("testFile")
		     writer = @mr_obj.to_marc_export(fh)
		     writer.should be_kind_of MARC::Writer
		     File.exists?(fh).should eq true
		  end
		end
  end
end