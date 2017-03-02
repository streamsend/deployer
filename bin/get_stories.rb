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

  opt :final_commit, "The final commit or branch", type: :string, long: "final-commit", default: "master"
  opt :previous_release, "The previous release or commit", type: :string, long: "previous-commit"
  opt :pivotal_token, "The pivotal token", type: :string, long: "pivotal-token", default: @CREDS.pivotal_token
  opt :project_dir, "The project directory", type: :string, long: "project-dir", default: @CREDS.project_dir
  opt :verbose, "Verbose", default: false
end

unless options[:pivotal_token]
  options[:pivotal_token] = ENV["PIVOTAL_API_TOKEN"]
end

Trollop::die :pivotal_token, "must be set" unless options[:pivotal_token]
Trollop::die :project_dir, "must be set" unless options[:project_dir]

pivotal = PivotalActions.new(options[:pivotal_token])

release = Release.new(options[:project_dir], options[:previous_release], options[:final_commit])
git_log = release.commits

final_commit = git_log.first.split(" ")[0]
stories_hash = release.stories_from_commits(git_log)

puts "As of #{final_commit}"
puts ""

not_stories = []
stories = []
commits_by_story = Hash.new
stories_hash.each do |storyid, commits|
  story_id = storyid.dup
  if story_id.match(%r/^#.*/)
    story_id.slice!(0)
  end

  story = pivotal.story(story_id)
  if story
    stories << story
  end
  commits_by_story[story_id.to_i] = commits
end
not_stories = stories_hash["None"] if stories_hash["None"]

states = ["accepted", "delivered", "finished", "started", "unstarted", "planned", "rejected", nil]

stories_sorted = stories.sort_by { |story|
  state_index = story.project_id
  raise "unknown state #{story.current_state}" if states.index(story.current_state).nil?
  state_index += states.index(story.current_state)
  state_index
}

last_project = "nothing"

stories_sorted.each do |story|
  project_name = (pivotal.project_for_story story).name
  if project_name != last_project
    puts project_name + "\n"
    last_project = project_name
  end
  puts release.describe_story(story, pivotal)
  commits = commits_by_story[story.id]
  if commits.nil?
    puts "(no commits) for #{story.id}?"
  end

  if options[:verbose]
    puts release.describe_commits_list commits_by_story[story.id]
  else
    if story.current_state != 'accepted'
      puts release.describe_commits_brief commits_by_story[story.id]
    end
  end
end

puts
puts "Commits with no story ids:"
puts

not_stories.reject! { |commit| commit[:line] =~ /^\w{7} Merge branch/ }
not_stories.each do |commit|
  puts " * #{commit[:line]}"
end

# Misc items to report...

#Find new Delayed Jobs

puts "\nDelayed Jobs"
release.git_diff_grep('app/jobs').each do |value|
  print " * #{value}\n"
end

puts "\nGems\n"
release.git_diff_file('Gemfile').each do |value|
  puts " * #{value}"
end
puts
release.git_diff_file('Gemfile.lock').each do |value|
  puts " * #{value}"
end

puts "\nMigrations"
release.git_diff_grep('db/migrate').each do |value|
  puts " * #{value}"
end

puts "\nRake Tasks"
release.git_diff_grep('lib/tasks').each do |value|
  puts " * #{value}"
end

puts "\nConfig Files"
release.git_diff_grep('config/', 'routes.rb').each do |value|
  puts " * #{value}"
end

puts
