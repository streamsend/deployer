#!/usr/bin/env ruby

require_relative "../lib/pivotal.rb"
require_relative "../lib/release.rb"
require "yaml"
require "ostruct"
require "trollop"

options = Trollop::options do
  @CREDS = OpenStruct.new(YAML.load_file('config/creds.yml'))

  banner <<-TEXT
        Pivotal Release Notes Generator

            Usage: get_stories.rb [options]
  TEXT

  opt :previous_version, "The last released version", type: :string
  opt :pivotal_token, "The pivotal token", type: :string, default: @CREDS.pivotal_token
  opt :project_dir, "The project directory", type: :string, default: @CREDS.project_dir
  opt :verbose, "Verbose", default: false
end

unless options[:pivotal_token]
  options[:pivotal_token] = ENV["PIVOTAL_API_TOKEN"]
end

Trollop::die :pivotal_token, "must be set" unless options[:pivotal_token]
Trollop::die :project_dir, "must be set" unless options[:project_dir]

pivotal = PivotalActions.new(options[:pivotal_token])

release = Release.new(options[:project_dir], options[:previous_version])
git_log = release.commits

last_commit = git_log.first.split(" ")[0]
stories_hash = release.stories_from_commits(git_log)

puts "As of #{last_commit}"
puts ""

stories_hash.each do |storyid, commits|
  story = pivotal.story(storyid)
  if story
    puts release.describe_story(story, pivotal)
  else
    puts "* not-a-story #{storyid}"
  end
  if options[:verbose]
    puts release.describe_commits_list commits
  else
    puts release.describe_commits_brief commits
  end
  puts ""
end

# Misc items to report...

#Find new Delayed Jobs
puts "\nDelayed Jobs"
release.git_diff_grep('app/jobs').each do |value|
  print "* #{value}\n"
end

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

