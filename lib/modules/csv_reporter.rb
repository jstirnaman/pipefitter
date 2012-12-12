require 'csv'
module CsvReporter
  class Import
    attr_accessor :data
    def initialize(filepath)
      # Create a table from a CSV file with headers
      @data = CSV.table(filepath)
    end
  end
  
  class Export
    def initialize(report_name, report_data)
			report_name = Rails.root.join('public/export/' + report_name + '_'+Time.now.strftime("%Y%m%d%h%m") + ".csv")
			if report_data.class == Array
				CSV.open(report_name, "wb") do |csv|
					header_keys = report_data.map {|w| w.keys}.flatten.uniq!
					csv << header_keys
					report_data.each do |w|
						csv << w.map {|k, v| v.class == Array ? v.join('|') : v }
					end         
				end
			elsif report_data.class == CSV::Table
				CSV.open(report_name, "wb") do |csv|
					report_data.each do |w|
						csv << w
					end
				end
			end
		end
  end
end