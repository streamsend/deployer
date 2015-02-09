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
    story = nil
    story ||= story_from_project(story_id, @latest_project) if @latest_project
    projects.collect do |project|
      story ||= story_from_project(story_id, project)
    end
    story
  end

  private

  def story_from_project(story_id, project)
    story = nil
    begin
      story = project.story(story_id)
      @latest_project = project
    rescue
      nil
    end
    story
  end

  def client
    @client ||= TrackerApi::Client.new(:token => @token)
  end

end
