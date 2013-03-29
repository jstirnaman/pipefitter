require 'spec_helper'

describe Ditare::OclcRecordset do
  
  context "with recordset from source" do
    before do
      @or_obj = Ditare::OclcRecordset.new({:q => 'accessmedicine'}) 
    end
     
		describe "SRU" do 
			it "returns an XML response from SRU" do
			  @or_obj.recordset.should be_a_kind_of Nokogiri::XML::Document
			end
		end
	  
  end
end