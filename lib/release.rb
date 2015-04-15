class Release

  def initialize(streamsend_dir, version)
    @dir = streamsend_dir
    @version = version
  end

  def commits
    git_log = git_command "git log --oneline #{@version}.."
    git_log.split "\n"
  end

  def stories_from_commits lines
    stories = {}
    lines.each do |line|
      commitid = line.split(" ")[0]
      storyId = story_from_commit commitid
      commits_for_story = stories[storyId.to_s] || []
      commits_for_story << {:commit_id => commitid, :line => line}
      stories[storyId.to_s] = commits_for_story
    end
    stories
  end

  def story_from_commit commit
    git_output = git_command "git show --format=%B #{commit}"
    story_match = git_output.match(/\nStory:\s*(.*?)\s*\n/m)
    if story_match
     story_match.captures[0]
    else
      "None"
    end
  end

  def print_story(story, pivotal)
    puts " * #{story.name}"
    puts "   * Pivotal Tracker [#{story.url} #{story.id}]"
    puts "     * #{story.story_type},  #{story.current_state} #{story.accepted_at.to_s}, PROJECT = #{(pivotal.project_for_story story).name}"
  end

  def git_diff_grep match_string
    git_log = git_command "git diff --name-only #{@version}.. | grep #{match_string}"
    git_log.split "\n"
  end

  def git_diff_file file
    git_log = git_command "git diff #{@version}.. -U0 #{file}"
    git_log.split "\n"
  end

  private

  def git_command command
    `cd #{@dir} && #{command}`
  end
end
