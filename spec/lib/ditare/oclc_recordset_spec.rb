require 'spec_helper'

describe Ditare::OclcRecordset do
  
  context "with recordset from source" do
    before do
      # Recordset from SRU search results.
      @or_sru = Ditare::OclcRecordset.new({:q => 'accessmedicine'})
      # Recordset with single record matching identifier.
      @or_get = Ditare::OclcRecordset.new({:i => 51502184})
    end
     
		describe "sru query" do 
		  it "returns an XML string from SRU query" do 
		    @or_sru.find_all.should be_a_kind_of String
		  end
			it "returns an XML response from SRU" do
			  @or_sru.to_marcxml.should be_a_kind_of Nokogiri::XML::Document
			end
			it "returns at least one matching record" do
		    xml = @or_sru.to_marcxml
		    xml.css('collection').children.size.should be >= 1
	    end
		end
		
		describe "identifier query" do
		  it "returns a single matching record" do
		    nodes = @or_get.to_record_nodeset
		    nodes.size.should eq 1
		    xml = @or_get.to_marcxml
		    xml.root.name.should eq 'collection'
		    xml.css('collection').children.size.should eq 1
	    end
	  end
  end
  
end