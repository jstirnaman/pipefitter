require 'spec_helper'

describe Ditare::EnrichmentSet do
  
  context "with Enrichment Set client" do
    before do
      @es_obj = Ditare::EnrichmentSet.new({:field => 'database_name', :q => '.*'})
    end
     
		describe "recordset" do 
			it "should be Array" do
			  @es_obj.recordset.should be_a_kind_of Array
			end
		end
		
		describe "last_updated" do
		  it "should return last updated as a Time" do
		    updated = @es_obj.client.worksheet.updated
		    updated.should be_a_kind_of Time
		  end
		  
		  it "should write the updated Time to a file for comparison" do
		    updated = @es_obj.client.worksheet.updated
		    file = Rails.root.to_s + "/log/tmp/google_drive_last_updated.txt"
		    File.exists?(file).should eq true
		    @es_obj.timestamp
		    @es_obj.changed?.should eq false  
		  end
		end
		
  end
end