# Rake tasks for Pipefitter

namespace :pipefitter do
  desc 'Compares import file titles to holdings in link resolver knowledgebase.'
  task :report_eresource_holdings => :environment do
    puts "\n\n== Comparing title holdings in file with eresource holdings."
    begin
      unless ARGV.empty?
        path = ARGV[1]
        path = Rails.root.join(path)
        table = CsvReporter::Import.new(Rails.root.join(path))
        
        p table.data.size.to_s + " rows " + " in " + path.to_s
        p "with headers: " + table.data.headers.join(', ')
        table.data.each do |row|
          e = ''
          if row[:issn]
            p row[:issn]
            e = EResourceHolding.new({:issn => row[:issn]}) 
          elsif row[:title]
            p row[:title]
            e = EResourceHolding.new({:title => row[:title]})
          end
          row["local_holdings"] = e.kb_holdings.holdings?.to_s
          #row["local_holdings", e.kb_holdings.holdings?]
          sleep(1) # Throttle API requests; wait a second before processing next row.
        end
        p e.kb_holdings.holdings?
        CsvReporter::Export.new("eresource_holdings", table.data)
      else
      puts "### ERROR - No file supplied ###"
      end
    rescue RuntimeError
      puts "### ERROR - Comparing eresource holdings ###"
    end
  end
end
