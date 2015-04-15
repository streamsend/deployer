require "active_support"
require "tracker_api"

class PivotalActions
  ActiveSupport::Deprecation.silenced = true

  def initialize(token)
    @token = token
    @project_stories = {}
  end

  def projects
    @projects ||= client.projects
  end

  def project_for_story story
    projects.each do |project|
      return project if story.project_id == project.id
    end
  end

  def story(story_id)
    if story_id.match(%r/^\d+$/)
      project = projects.detect do |project|
        story_ids = @project_stories[project.id]
        unless story_ids
          story_ids = project.stories.map(&:id)
          @project_stories[project.id] = story_ids
        end
        story_ids.include?(story_id.to_i)
      end
      project.story(story_id) if project
    end
  end

  private

  def client
    @client ||= TrackerApi::Client.new(:token => @token)
  end
end
