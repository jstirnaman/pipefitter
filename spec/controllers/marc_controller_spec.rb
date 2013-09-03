require 'spec_helper'

describe MarcController do

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
	end
end