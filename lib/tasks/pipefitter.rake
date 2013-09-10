# Rake tasks for Pipefitter

namespace :pipefitter do
  desc 'Compares import file titles to holdings in link resolver knowledgebase.'
  task :report_eresource_holdings => :environment do
    puts "\n\n== Comparing title holdings in file with eresource holdings."
    begin
      include DitareCsv
      unless ARGV[1].nil?
        path = ARGV[1]
        path = Rails.root.join(path)
        # Set encoding. ASCII-8BIT for Serials Solutions reports.
        table = DitareCsv.import_csv(Rails.root.join(path), {:encoding => "ASCII-8BIT"})
        
        p table.size.to_s + " rows " + " in " + path.to_s
        p "with headers: " + table.headers.join(', ')

        holdings = []
        table.each do |row|
          q = {:issn => row[:issn]} unless row[:issn].nil?
          q ||= {:title => row[:title]}
          e = SerialsSolutions::Openurl::Client.new(q)
          p q.to_s + "? " + e.holdings?.to_s
          holdings << e.holdings?.to_s
          sleep(0.3) # Throttle API requests; pause before processing next row.
        end
        # Fill a new local_holdings column with holdings?.to_s and write the file.
        table["local_holdings"]= holdings
        DitareCsv.export_csv("eresource_holdings", table)
      else
      puts "### ERROR - No file supplied ###"
      end
    rescue RuntimeError
      puts "### ERROR - Comparing eresource holdings ###"
    end
  end
 
  desc 'Fetches a MARC record for each resource in enrichments. 
        Enriches fetched MARC records with EZProxy link and enrichment data.
        Accepts 2 arguments:
        pipefitter:enrich_marc[true] forces the task to run even if 
        Enrichments have not changed.
        pipefitter:enrich_marc[true|false, `path to list of bib record ids`]
        enriches the bib records specified in a list of record ids.'
  task :enrich_marc, [:force, :batch_ids] => [:environment] do |t, args|
    puts "\n\n == Checking if enrichments source has changed."
    @es = Ditare::EnrichmentSet.new({:field => "database_name", :q => ".*"})
    if args[:force] or @es.changed?
      puts "\n\n == Force was set to " + args[:force].to_s
      puts "\n\n == Enrichments file changed? " + @es.changed?.to_s
      
      if args[:batch_ids] and !args[:batch_ids].empty?
        puts "Reading batch file #{args[:batch_ids]}..."
        batch = IO.readlines(args[:batch_ids])
        batch = batch.map{|line| line.to_i unless line.to_i == 0}.compact
        
        puts "Attempting to fetch #{batch.size} records"
        mr = Ditare::MarcRecordset.new(:oclc, {})
        out_file = File.new(mr.export_file("_batch-enriched_"), "a")

        batch.each do |rec_id|
          begin
            puts "#### Next Record ####"
            puts "Record ID #{rec_id}"
            mrs = Ditare::MarcRecordset.new(:oclc, {:i => rec_id})
            mrs = mrs.enriched
            out_file.write(mrs.recordset)
          rescue StandardError => e
            puts e.inspect
          end     
        end
       
       puts "Finished!"
      
      end
        
        # If resource not in EZProxy, find the best OCLC match using the available data.
        # If we have an OCLC record, enrich it and write the MARC result to a file. 

    else
      # Do nothing
    end
    
  end

  desc 'Generates hits against EZProxy-configured resources.'
  task :generate_proxy_hits_from_menu => :environment do
    ec = Ezproxy::Client.new
    a = ec.agent
    click_links(a)
  end

  desc 'Scrapes database URLs from list in databases webpage.'
  task :generate_proxy_hits_from_dblist => :environment do
    include CasMechanizer
    @agent = Mechanize.new
    @store = cas_auth_store
    @page = @agent.get("http://library.kumc.edu/database-list/")
    EZPROXY_BASE_URL = API_CONFIG['EZPROXY']['BASE_URL']
    new_links = @page.links_with(:href => /login\.proxy/).map do |link|
        EZPROXY_BASE_URL + '/login' + link.uri.to_s[/(\?URL=.*)/, 0]
    end
   unless new_links.empty?
     al = Mechanize::AGENT_ALIASES.values
     new_links.each do |link|
       @agent.user_agent = al.shuffle.first
       begin
         mechanize_authentication(link)
       rescue StandardError => e
         puts e.inspect + link.inspect
       end
     end
   end
  end

  def click_links(agent)
     al = Mechanize::AGENT_ALIASES.values
       agent.page.links.each do |link|
         agent.user_agent = al.shuffle.first
           begin
             agent.transact do
               link.click
             end
           rescue StandardError => e
             puts e.inspect + link.inspect
           end
       end
  end
end
