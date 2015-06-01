require 'date'
require 'fileutils'
require 'nokogiri'

FileUtils.mkdir_p("html")

date =  Date.new(2015,4,9)

for episode in 1..50
    str_date = date.strftime("%0Y/%m/%d")
    puts "##{episode} - #{str_date}"
    link = "http://www.tor.com/#{str_date}/hoshruba-the-land-and-the-tilism-book-1-episode-#{episode}/"
    puts "Download #{link}"
    `wget --no-clobber "#{link}" --output-document "html/#{episode}.html" -o /dev/null`
    date+=1 if episode >= 7
end

# Now we have all the files
html = ""
for i in 1..50
    html += "<h1>Chapter #{i}</h1>"
    page = Nokogiri::HTML(open("html/#{i}.html")).css('.entry-content')
    start = ending = false
    pass = 0
    page.children.each do |e|
        e.name = 'h4' if e.name == 'h3'

        ending = true if e.attribute('class') and e['class'].include? 'post-end-spacer'

        if !start or ending
            e.remove
        end
        
        start = true if e.inner_text.end_with? 'Barnes & Noble or Amazon.'
        pass+=1
    end
    html += page.inner_html
end

# Write it in the book
File.open("Hoshruba.html", 'w') { |file| file.write(html) }
