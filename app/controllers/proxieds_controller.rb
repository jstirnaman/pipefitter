class ProxiedsController < ApplicationController
  include Ezproxy #api/ezproxy.rb
  include Ditare
  
  attr_accessor :client
  
  respond_to do |format|
    format.html
    format.json
    format.jsonp
    format.xml
  end
  
  def initialize
    @client = Ezproxy::Client.new
  end

  def proxy_hashes(proxy_objs)
		proxy_objs.collect do |p|
				h = Hash.new
				h[:text] = p.text
				h[:href] = p.href
				h
		end
  end
  
  def index
    @query = params[:q] || '.*'
    # Accept string or regexp. If string, convert to regexp.
    query = @query.class == Regexp ? @query : %r/^#{@query}/i
    #Returns links that have text_value matching the query, e.g. find("pubmed")
    #Array of Mechanize::Page::Links objects
    unless @proxieds
			@proxieds = client.links({:text => query})
			#Return an array of hashes that we can alter with other methods
			#Must be time to move this into a model.
			@proxieds = proxy_hashes(@proxieds)
    end
    @proxieds
  end
  
  def show
    @query = params[:q]
    query = %r/^#{@query}$/i
    @proxieds = client.links({:text => query})
  end
  
  def oclc
    # Return OCLC record ids that match proxied resource title
    @query = params[:q] || '.*'
    # Accept string or regexp. If string, convert to regexp.
    query = @query.class == Regexp ? @query : %r/^#{@query}/i
    #Returns links that have text_value matching the query, e.g. find("pubmed")
    #Array of Mechanize::Page::Links objects
    @proxieds = client.links({:text => query})
    #Return an array of hashes that we can alter with other methods
    #Must be time to move this into a model.
    @proxieds = proxy_hashes(@proxieds)
    @proxieds = @proxieds.map do |p|
      h = Hash.new
      h[:oclc_id] = []
      Ditare::MarcRecordset.new(:oclc, {:q => p[:text]})
        .read.each do |rec|
          h[:oclc_id] << rec['001'].value
        end
      p.merge(h)
    end
    render :action => "index"
  end
  
  def api(params)
    supported_apis = [:ezproxy] # Use some validator for this?
    if supported_apis.include?(params[:api].to_sym) 
      api = params[:api]
    end
  end
end

