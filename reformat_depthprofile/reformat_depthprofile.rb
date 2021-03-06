#!/usr/bin/ruby

require 'optparse'
require 'csv'
$VERBOSE=nil

#not indenting, everything is in this block
ARGV.each {|file|

nmasses = 0
input = File.new(file, "r")
puts file	
while (line = input.gets)
	if(line.include?("B =")) then nmasses = nmasses+1 end
end
input.close
puts "nmasses: #{nmasses}"

csv = Array.new()
CSV.open(file, "r", "\t") do |row|
	csv << row
end

#puts csv
#csv.each {|r| r.each {|c| print c }; puts ""; }
#puts "\n\n ************************* \n"
#csv.delete_at(0)

csv.delete_if {|r| r==[nil]}

csv.each {|r| r.delete_if { |c| c==nil } }
csv.each {|r| r.each_index {|i| if r[i]=="X" then r[i]="Time" end } }

csv.each_index {|i| 
	csv[i].each_index {|j|
		if csv[i][j]=="Y" then
			csv[i][j]=csv[i-1][0]
			csv.delete_at(i-1)
		end
	}
}

csv.each_index {|i| 
	csv[i].each_index {|j|
		if csv[i][j].include?("B") then
			temp = csv[i][j]
			temp = temp.reverse
			temp = temp.slice(0, temp.rindex("M")+1)
			temp = temp.reverse
			temp = temp.slice(0, temp.rindex("("))
			temp.chomp!
			csv[i][j] = temp
		end
	}
}


#csv.each {|r| r.each {|c| print c+", " }; puts ""; }

offset = 0
size = (csv.length)/nmasses

shifted = Array.new()
s=size

for r in (1..size)
	temparr = [csv[r][0]]
	for i in (0..nmasses-1)
		temparr = temparr + [csv[r+(i*s)][1]]
	end #, csv[r][1], csv[r+s][1], csv[r+2*s][1], csv[r+3*s][1], csv[r+4*s][1]]
	shifted.push(temparr)
end

#shifted.each_index {|i|
#	for j in (0..(size-1))  
#		shifted[i].push(csv[j+(offset*size)][1])
#	end
#	offset=offset+1
#}


#csv.each {|r| r.each {|c| print c+", " }; puts ""; }
#puts "\n\n ************************* \n"

#shifted.each {|r| r.each {|c| print c+", " }; puts ""; }

newname = file.slice(0, file.rindex("."))
newname = newname << "_dp.csv"

outfile = File.open(newname, 'wb')

CSV::Writer.generate(outfile) do |foo|
	shifted.each {|r|
		foo << r
	}
end

outfile.close

}  #end of ARGV.each block


