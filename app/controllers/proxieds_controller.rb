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
  
  def index
    @query = params[:q] || '.*'
    # Accept string or regexp. If string, convert to regexp.
    query = @query.class == Regexp ? @query : %r/^#{@query}/i
    #Returns links that have text_value matching the query, e.g. find("pubmed")
    #Array of Mechanize::Page::Links objects
    unless @proxieds
			@proxieds = client.links_to_hash({:text => query})
    end
    @proxieds
  end
  
  def show
    @query = params[:q]
    query = %r/^#{@query}$/i
    @proxieds = client.links({:text => query})
  end
  
  def related
    unless @proxieds
      index
    end
    oclc_records
    enrichments_records
    render :action => "index"
  end
  
  def oclc
    unless @proxieds
      index
    end
    oclc_records
    render :action => "index"
  end
  
  def oclc_records
    @proxieds = @proxieds.map do |p|
      h = Hash.new
      h[:oclc_id] = []
      # Search MARC SRU source for the EZProxy target host, e.g. 'www.accessmedicine.com'
      Ditare::MarcRecordset.new(:oclc, {:q => 'srw.kw=' + p[:target].host})
        .read.each do |rec|
          h[:oclc_id] << rec['001'].value
        end
      p.merge(h)
    end  
  end
  
  def enrichments
    unless @proxieds
      index
    end
    enrichments_records
    render :action => "index"    
  end
  
  def enrichments_records
    @proxieds = @proxieds.map do |p|
      h = Hash.new
      h[:enrichments] = []
      e = Ditare::EnrichmentSet.new({:field => 'database_name', :q => p[:text]})
      e.recordset.each do |r|
        # Convert GData object to hash
        h[:enrichments] << Hash.try_convert(r)
      end
      p.merge(h)
    end  
  end
  
  def api(params)
    supported_apis = [:ezproxy] # Use some validator for this?
    if supported_apis.include?(params[:api].to_sym) 
      api = params[:api]
    end
  end
end

