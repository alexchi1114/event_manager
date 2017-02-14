require "csv"
require "sunlight/congress"
require 'erb'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode) 
	zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zipcode)
	Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

def clean_phone(phone)
	without_hyphen=phone.gsub(/[^0-9]/,"")
	if without_hyphen.length==11
		if without_hyphen[0]==1
			without_hyphen[0..9].insert(-8, '-').insert(-5, '-')
		else
			"000-000-0000"
		end
	elsif without_hyphen.length!=10
		"000-000-0000"
	else
		without_hyphen.insert(-8, '-').insert(-5, '-')
	end
end

contents=CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
template_letter=File.read "form_letter.erb"
erb_template=ERB.new template_letter
contents.each do |row|
	id=row[0]
	name = row[:first_name]
	phone = clean_phone(row[:homephone])
	zipcode=clean_zipcode(row[:zipcode])
	legislators=legislators_by_zipcode(zipcode)
	form_letter=erb_template.result(binding)
	save_thank_you_letters(id,form_letter)
end
