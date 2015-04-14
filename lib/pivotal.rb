require "tracker_api"

class PivotalActions

  def initialize(token)
    @token = token
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
    if @latest_project
      story = story_from_project(story_id, @latest_project)
    else
      projects.detect do |project|
        story = story_from_project(story_id, project)
      end
    end
    story
  end

  private

  def story_from_project(story_id, project)
    begin
      story = project.story(story_id)
      @latest_project = project
    rescue
      story = nil
    end
    story
  end

  def client
    @client ||= TrackerApi::Client.new(:token => @token)
  end
end
