class Release

  def initialize(streamsend_dir, initial_commit = nil, final_commit = "master")
    @dir = streamsend_dir
    @initial_commit = initial_commit
    @final_commit = final_commit
    unless @initial_commit
      @initial_commit = git_latest_tag
    end
    checkout(final_commit)
  end

  def commits
    command = "git log --oneline #{@initial_commit}..#{@final_commit}"
    git_log = git_command command
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
    git_output = git_command "git log -n 1 #{commit}"
    story_match = git_output.match(/Story:\s*.*?(\d+)/m)
    if story_match
     story_match.captures[0]
    else
      "None"
    end
  end

  def describe_commits_list commits
    output = []
    commits.each do |commit|
      output << "       * #{commit[:line]}"
    end
    output.join("\n")
  end

  def describe_commits_brief commits
    ids = commits.map do |commit|
      commit[:commit_id]
    end
    "      * commits: #{ids.join(',')}"
  end

  def describe_story(story, pivotal)
    output = " * #{story.name}"
    if story.current_state == 'accepted'
      state = "#{story.current_state} #{story.accepted_at.to_s}"
    else
      state = "'''''" + story.current_state + "'''''"
    end
    output += "\n   * Pivotal Tracker [#{story.url} #{story.id}], #{story.story_type}, #{state}"
  end

  def git_latest_tag
    git_command("git describe --abbrev=0 --tags --match \"v[1-9].*\"").chomp
  end

  def git_diff_grep match_string
    git_log = git_command("git diff --name-only #{@initial_commit}.. | grep #{match_string}")
    git_log.split("\n")
  end

  def git_diff_file file
    git_log = git_command "git diff #{@initial_commit}.. -U0 #{file}"
    git_log.split "\n"
  end

  def git_tag_checked_out?(tag)
    git_line = git_command("git log -n 1 --decorate --pretty=oneline")
    git_line.include?(tag)
  end

  private

  def checkout(commit)
    unless git_tag_checked_out?(commit)
      git_command("git checkout #{commit}")
    end
  end

  def git_command command
    original_dir = Dir.pwd
    `cd "#{@dir}" && #{command} && cd "#{original_dir}"`
  end
end
