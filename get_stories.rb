#!/usr/bin/env ruby

require "./pivotal.rb"
require "./release.rb"
require "yaml"
require "ostruct"


@CREDS = OpenStruct.new(YAML.load_file('config/creds.yml'))
raise "pivotal_token not scecified in creds.yml" unless  @CREDS.pivotal_token
pivotal = PivotalActions.new(@CREDS.pivotal_token)

release = Release.new(@CREDS.streamsend_dir, @CREDS.previous_version)
git_log = release.commits

last_commit = git_log.first.split(" ")[0]
stories_hash = release.stories_from_commits(git_log)

puts "As of #{last_commit}"
puts ""

stories_hash.each do |storyid,v|
  story = pivotal.story(storyid)
  if story
    release.print_story(story, pivotal)
  else
    puts "* not-a-story #{storyid}"
  end

  v.each do |commit|
    puts "      *  #{commit[:line]}"
  end
end

# Misc items to report...

#Find new Delayed Jobs
puts "\nDelayed Jobs"
release.git_diff_grep('app/jobs').each do |value|
  print "* #{value}\n"
end

#git diff --name-only v2.95.. | grep app/jobs

puts "\nGems\n"
release.git_diff_file('Gemfile').each do |value|
  puts "* #{value}"
end
release.git_diff_file('Gemfile.lock').each do |value|
  puts "* #{value}"
end

puts "\nMigrations"
release.git_diff_grep('db/migrate').each do |value|
  puts "* #{value}"
end


puts "\nRake Tasks"
release.git_diff_grep('lib/tasks').each do |value|
  puts "* #{value}"
end

puts

