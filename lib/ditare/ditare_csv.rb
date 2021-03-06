require 'csv'
module DitareCsv
  class << self
    attr_accessor :data, :file
    def initialize(options)
      @file = options[:file]
      @data = options[:data]
    end
    
    def import_csv(file, options)
      # Create a table from a CSV file with headers
      @data = CSV.table(file, options)
    end
  
		def export_csv(file, data)
				report_name = Rails.root.join('public/export/' + file + '_'+Time.now.strftime("%Y%m%d%H%M") + ".csv")
				if data.class == Array
					CSV.open(report_name, "wb") do |csv|
						header_keys = data.map {|w| w.keys}.flatten.uniq!
						csv << header_keys
						data.each do |w|
							csv << w.map {|k, v| v.class == Array ? v.join('|') : v }
						end         
					end
				elsif data.class == CSV::Table
					File.open(report_name, "wb") do |f|
            f << data.to_csv
					end
				end
    end 
  end
end
