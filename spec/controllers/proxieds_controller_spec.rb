require 'spec_helper'

describe ProxiedsController do

  context "with options" do
    before :all do
      @query = 'PubMed'
		end
  
		describe "GET #show" do
			it "returns http success" do
				get :show, q: @query
				response.should be_success
			end
		end

		describe "GET #index" do
			it "returns http success" do
				get :index
				response.should be_success
			end
		
			it "matches a query q = #{@query}" do
			  get :index, q: @query
			  expect(assigns(:proxieds).first).to be_a_kind_of Hash
			  expect(assigns(:proxieds).first[:text]).to match(@query)
			end
		end
		
		describe "GET #index/#oclc" do
		  it "returns a collection of hashes containing OCLC ID" do
		    get :oclc, q: @query
		    expect(assigns(:proxieds).first[:oclc_id]).to be_true
		  end
		end
		
		describe "GET #index/#enrichments" do
		  it "returns a collection of hashes containing Enrichments" do
		    get :enrichments, q: @query
		    expect(assigns(:proxieds).first[:enrichments]).to be_true
		  end
		end
		
		describe "GET #show/#related/" do
		  it "returns the first match from query results" do
		  end
		  
		  it "returns a marc record for the first match that includes the proxy and all enrichments" do
      end
    end
  end
end
