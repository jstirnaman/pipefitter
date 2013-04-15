# Scrapes your EZProxy /menu page to find the list of configured resources and URLs.
module Ezproxy

  class Client
    include CasMechanizer
    
    attr_accessor :agent, :store, :page
    EZPROXY_BASE_URL = API_CONFIG['EZPROXY']['BASE_URL']
    
    def initialize()
      @agent = Mechanize.new
      @agent.log = Logger.new "mechanize-ezproxy.log"
      @agent.user_agent_alias = 'Mac FireFox'
      # Store CAS credentials.
      @store = cas_auth_store
      # Return a Mechanize Page object from the content at URL.
      #@page = @agent.get(API_CONFIG['EZPROXY']['BASE_URL']+'/menu')
      @page = mechanize_authentication(EZPROXY_BASE_URL + '/menu')
    end
    
    def links(options)
      # Mechanize returns array of matching Mechanize::Page::Link objects with a.content, a.href
      options.merge({:href => %r/#{EZPROXY_BASE_URL}/})
      links = page.links_with(options)
    end
    
    def links_to_hash(options)
      # Returns array of link objects as hashes.
      links = links(options).collect do |l|
				h = Hash.new
				h[:text] = l.text				
				h[:uri] = l.uri # Returns href attribute as a fully parsed uri.
				h[:target] = target_domain(l.uri)
				h
			end
    end
    
    def target_domain(uri)
      unless uri.query.nil?
        URI(uri.query.sub('url=', '')) # Return url parameter as a fully parsed uri.
      else
        URI('')
      end
    end
    
    def with_marc(options)
      records = links_to_hash(options)
			proxied_with_marc = records.map do |l|
				# Search MARC SRU source for the EZProxy target host, e.g. 'www.accessmedicine.com'
				target_arr = l[:target].host.split('.')
				target_name = target_arr[-2] # For searching first part of domain name as title or kw.
				target_primary_domain = target_arr.last(2).join('.') # For searching primary domain name as 856u.
				# Search for primary domain in 856u (accessmethod) AND any words from link text in 245 (title).
				marc = Ditare::MarcRecordset.new(:oclc, {:q => 'srw.am='+ target_primary_domain + 
																								' and ' + 'srw.ti ANY ' + '"' + l[:text] + '"' })
				l[:marc] = []
				l[:marc] << marc
				l
			end
    end
    
    def with_marc_hash(options)
      records = links_to_hash(options)
			proxied_with_marc = records.map do |l|
				# Search MARC SRU source for the EZProxy target host, e.g. 'www.accessmedicine.com'
				target_arr = l[:target].host.split('.')
				target_name = target_arr[-2] # For searching first part of domain name as title or kw.
				target_primary_domain = target_arr.last(2).join('.') # For searching primary domain name as 856u.
				# Search for primary domain in 856u (accessmethod) AND any words from link text in 245 (title).
				marc = Ditare::MarcRecordset.new(:oclc, {:q => 'srw.am='+ target_primary_domain + 
																								' and ' + 'srw.ti ANY ' + '"' + l[:text] + '"' })
				l[:marc] = []
				marc.read.each do |rec|
						l[:marc] << rec.to_hash
				end
				l
			end
    end

    private

    def format_id_param(id)
      Array(id).join('/')
    end
    
    def hash_from_menu
    # Parse the HTML doc and find the paragraph element containing the list of links.
      #body = doc.css('body')
      #menu = body.xpath("/p[a[contains(@href, '/login?url=')]]")
    end
  end
end