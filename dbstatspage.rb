#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'psych'
require 'bundler/setup'
require 'cinch-bag'
require 'cinch-hangouts'

# GROSS AS HELL; but whatever, it's irc shit.

def html_head
  "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
  <html xmlns='http://www.w3.org/1999/xhtml'>
    <head>
      <meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1' />
      <title>#enforcers @ Slashnet stats by Asmer</title>
      <link href='css/bootstrap.min.css' rel='stylesheet' media='screen'>
      <link rel='stylesheet' type='text/css' title='estats' href='/css/estats.css' />
      <script src='http://code.jquery.com/jquery.js'></script>
      <script src='js/bootstrap.min.js'></script>
    </head>
    <body>
      <div align='center'>
        <div class='navbar navbar-fixed-top navbar-inverse'>
          <div class='navbar-inner'>
            <div class='container'>
              <a class='brand' href='#'>#enforcers @ Slashnet stats by Asmer</a>
              <ul class='nav'>
                <li><a href='/'>Channel Stats</a></li>
                <li><a class='active'}' href='dickbag.html'>Dickbag</a></li>
                <li><a class='active'}' href='karma.html'>Karma</a></li>
                <li><a class='active'}' href='hangouts.html'>Hangouts</a></li>
                <li><a href='http://shitenforcerslink.tumblr.com/'>Link Logger</a></li>
              </ul>
            </div>
          </div>
        </div>
        <div class='container'>
          <div class='row'>
            <div class='content span10 offset1'>"
end

def html_foot
  '         </div>
          </div>
        </div>
      </div>
    </body>
  </html>'
end

def time_format(secs)
  data = time_parse(secs)
  string = ''

  string << "#{data[:days]}d "  unless data[:days].zero?  && string == ''
  string << "#{data[:hours]}h " unless data[:hours].zero? && string == ''
  string << "#{data[:mins]}m "  unless data[:mins].zero?  && string == ''
  string << "#{data[:secs]}s"

  return string
end

def time_parse(secs)
  days = secs / 86400
  hours = (secs % 86400) / 3600
  mins = (secs % 3600) / 60
  secs = secs % 60

  return { :days => days.floor,
           :hours => hours.floor,
           :mins => mins.floor,
           :secs => secs.floor }
end

@db_filename = '/home/bhaberer/src/bender/yaml/bag_status.yml'
@db_htmlpage = '/home/bhaberer/src/pisg/estats/dickbag.html'
@karma_filename = '/home/bhaberer/src/bender/yaml/karma.yml'
@karma_htmlpage = '/home/bhaberer/src/pisg/estats/karma.html'
@hangouts_filename = '/home/bhaberer/src/bender/yaml/hangouts.yml'
@hangouts_htmlpage = '/home/bhaberer/src/pisg/estats/hangouts.html'

# Get Dickbag stats
@data = Psych.load(File.open(@db_filename))
@stats = []

@data[:stats].each_pair do |user, data|
  @stats << { :nick  => user,
              :time  => data.time,
              :count => data.count }
end

@stats.sort! {|x,y| y[:count] <=> x[:count] }
@topcounts = @stats[0..49]
@stats.sort! {|x,y| y[:time] <=> x[:time] }
@toptimes = @stats[0..49]

# Get Karma stats
@data = Psych.load(File.open(@karma_filename))
@karma = []

@data['#enforcers'].each_pair do |item, count|
  @karma << { :item => item, :count => count }
end
@karma.sort! {|x,y| y[:count] <=> x[:count] }
#@karma = @karma[0..199]
@karma.delete_if { |k| k[:count].zero? }

# Get Hangouts
@data = Psych.load(File.open(@hangouts_filename))
@hangouts = []

@data[:hangouts].each_pair do |item, hangout|
  @hangouts << { nick:  hangout.nick,
                 id:    hangout.id,
                 time:  hangout.time }
end

# Build Pages

# hangouts
@hangouts_html_out = html_head
@hangouts_html_out << "
            <br>
            <div class=\"row\">
              <div class=\"span6 offset2\">
                <table class=\"table table-condensed table-bordered table-striped\">
                  <thead>
                    <th>Started By</th>
                    <th>Time</th>
                    <th>Link</th>
                  </thead>"
@hangouts.each do |hangout|
  @hangouts_html_out << "<tr><td>"
  @hangouts_html_out << hangout[:nick]
  @hangouts_html_out << "</td><td>"
  @hangouts_html_out << hangout[:time].strftime("%H:%M")
  @hangouts_html_out << "</td><td>"
  @hangouts_html_out << "<a href='#{Hangout.url(hangout[:id])}'>Click to Join</a>"
  @hangouts_html_out << "</td></tr>"
end

@hangouts_html_out << "
                </table>
              </div>
            </div>
            <div class=\"row\">
              <div class=\"span6 offset2\">
                <div class=\"well text-center\">
                  Hangout List Updated at #{Time.now.strftime("%H:%M on %Y-%m-%d")}
                </div>
              </div>
            </div>"
@hangouts_html_out << html_foot



# dickbag

@db_html_out = html_head
@db_html_out << "
            <br>
            <div class=\"row\">
              <div class=\"span6 offset2\">
                <div class=\"well text-center\">
                  Stats Generated at #{Time.now.strftime("%H:%M on %Y-%m-%d")}
                </div>
              </div>
            </div>
            <div class=\"row\">
              <div class=\"span5\">
                <table class=\"table table-condensed table-bordered table-striped\">
                  <thead>
                    <th>Rank</th>
                    <th>Nick</th>
                    <th>Count</th>
                  </thead>"
@topcounts.each_with_index do |user,i|
  @db_html_out << "<tr><td>#{i + 1}</td><td>#{user[:nick]}</td><td>#{user[:count]}</td></tr>"
end

@db_html_out << '
                </table>
              </div>
              <div class="span5">
                <table class="table table-condensed table-bordered table-striped">
                  <thead>
                    <th>Rank</th>
                    <th>Nick</th>
                    <th>Time</th>
                  </thead>'
@toptimes.each_with_index do |user,i|
  @db_html_out << "<tr><td>#{i + 1}</td><td>#{user[:nick]}</td><td>#{time_format user[:time]}</td></tr>"
end

@db_html_out << '
                </table>
              </div>
            </div>'
@db_html_out << html_foot

# karma
@karma_html_out = html_head
@karma_html_out << "
            <br>
            <div class=\"row\">
              <div class=\"span6 offset2\">
                <div class=\"well text-center\">
                  Stats Generated at #{Time.now.strftime("%H:%M on %Y-%m-%d")}
                </div>
              </div>
            </div>
            <div class=\"row\">
              <div class=\"span6 offset2\">
                <table class=\"table table-condensed table-bordered table-striped\">
                  <thead>
                    <th>Rank</th>
                    <th>Karma Item</th>
                    <th>Count</th>
                  </thead>"
@karma.each_with_index do |user,i|
  @karma_html_out << "<tr><td>#{i + 1}</td><td>"
  if user[:item].length > 65
    @karma_html_out << "#{user[:item][0..65]}..."
  else
    @karma_html_out << user[:item]
  end
  @karma_html_out << "</td><td>#{user[:count]}</td></tr>"
end

@karma_html_out << '
                </table>
              </div>
            </div>'
@karma_html_out << html_foot

# Write pages
File.open(@db_htmlpage, 'w') do |file|
  file.puts @db_html_out
end
File.open(@karma_htmlpage, 'w') do |file|
  file.puts @karma_html_out
end
File.open(@hangouts_htmlpage, 'w') do |file|
  file.puts @hangouts_html_out
end
