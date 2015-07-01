require "spec_helper"
require_relative "../../lib/pivotal"

describe PivotalActions do
  let(:token) { "my_secret_token" }
  let!(:pivotal) { PivotalActions.new(token) }
  let(:story_id) { 12.to_s }
  let(:projects_response) do <<-JSON
[
   {
       "id": 98,
       "kind": "project",
       "name": "Learn About the Force",
       "version": 2,
       "iteration_length": 1,
       "week_start_day": "Monday",
       "point_scale": "0,1,2,3",
       "point_scale_is_custom": false,
       "bugs_and_chores_are_estimatable": false,
       "automatic_planning": true,
       "enable_tasks": true,
       "time_zone":
       {
           "kind": "time_zone",
           "olson_name": "America/Los_Angeles",
           "offset": "-07:00"
       },
       "velocity_averaged_over": 3,
       "number_of_done_iterations_to_show": 12,
       "has_google_domain": false,
       "enable_incoming_emails": true,
       "initial_velocity": 10,
       "public": false,
       "atom_enabled": true,
       "project_type": "private",
       "start_time": "2015-04-07T12:00:05Z",
       "created_at": "2015-04-07T12:00:10Z",
       "updated_at": "2015-04-07T12:00:15Z",
       "account_id": 100,
       "current_iteration_number": 1,
       "enable_following": true
   },
   {
       "id": 99,
       "kind": "project",
       "name": "Death Star",
       "version": 62,
       "iteration_length": 1,
       "week_start_day": "Monday",
       "point_scale": "0,1,2,3",
       "point_scale_is_custom": false,
       "bugs_and_chores_are_estimatable": false,
       "automatic_planning": true,
       "enable_tasks": true,
       "time_zone":
       {
           "kind": "time_zone",
           "olson_name": "America/Los_Angeles",
           "offset": "-07:00"
       },
       "velocity_averaged_over": 3,
       "number_of_done_iterations_to_show": 12,
       "has_google_domain": false,
       "description": "Expeditionary Battle Planetoid",
       "profile_content": "This is a machine of war such as the universe has never known. It's colossal, the size of a class-four moon. And it possesses firepower unequaled in the history of warfare.",
       "enable_incoming_emails": true,
       "initial_velocity": 10,
       "public": false,
       "atom_enabled": true,
       "project_type": "private",
       "start_date": "2014-12-22",
       "start_time": "2015-04-07T12:00:15Z",
       "created_at": "2015-04-07T12:00:10Z",
       "updated_at": "2015-04-07T12:00:15Z",
       "account_id": 100,
       "current_iteration_number": 15,
       "enable_following": true
   }
]
    JSON
  end
  let(:stories_response) do
    "[" + story_response + "]"
  end
  let(:story_response) do <<-JSON
{
   "created_at": "2015-04-07T12:00:00Z",
   "current_state": "unstarted",
   "description": "ignore the droids",
   "estimate": 2,
   "id": #{story_id},
   "kind": "story",
   "labels":
   [
   ],
   "name": "Bring me the passengers",
   "owner_ids":
   [
   ],
   "project_id": 98,
   "requested_by_id": 101,
   "story_type": "feature",
   "updated_at": "2015-04-07T12:00:00Z",
   "url": "http://localhost/story/show/555"
}
    JSON
  end

  before do
    stub_request(:get, "https://www.pivotaltracker.com/services/v5/projects").
      with(:headers => {'Host'=>'www.pivotaltracker.com:443', 'User-Agent' => /.+/, 'X-Trackertoken'=>'my_secret_token'}).
      to_return(:status => 200, :body => projects_response, :headers => {content_type: "application/json; potentially-other-variable-stuff"})

    stub_request(:get, "https://www.pivotaltracker.com/services/v5/projects/98/stories/#{story_id}").
      with(:headers => {'Host'=>'www.pivotaltracker.com:443', 'User-Agent'=> /.+/, 'X-Trackertoken'=>'my_secret_token'}).
      to_return(:status => 200, :body => story_response, :headers => {content_type: "application/json; potentially-other-variable-stuff", "X-Tracker-Project-Version" => 62})

    stub_request(:get, "https://www.pivotaltracker.com/services/v5/projects/99/stories/#{story_id}").
      with(:headers => {'Host'=>'www.pivotaltracker.com:443', 'User-Agent'=>/.+/, 'X-Trackertoken'=>'my_secret_token'}).
      to_return(:status => 200, :body => "{}", :headers => {content_type: "application/json; potentially-other-variable-stuff", "X-Tracker-Project-Version" => 62})

    stub_request(:get, "https://www.pivotaltracker.com/services/v5/projects/98/stories").
      with(:headers => {'Host'=>'www.pivotaltracker.com:443', 'User-Agent'=>/.+/, 'X-Trackertoken'=>'my_secret_token'}).
      to_return(:status => 200, :body => stories_response, :headers => {content_type: "application/json; potentially-other-variable-stuff", "X-Tracker-Project-Version" => 62})
    stub_request(:get, "https://www.pivotaltracker.com/services/v5/projects/99/stories").
      with(:headers => {'Host'=>'www.pivotaltracker.com:443', 'User-Agent'=>/.+/, 'X-Trackertoken'=>'my_secret_token'}).
      to_return(:status => 200, :body => "[]", :headers => {content_type: "application/json; potentially-other-variable-stuff", "X-Tracker-Project-Version" => 62})
  end

  it "gets the projects"  do
    expect(pivotal.projects.size).to eq 2
  end

  it "returns the story" do
    expect(pivotal.story(story_id).project_id).to eq 98
  end

  it "returns the project ids" do
    expect(pivotal.project_for_story(pivotal.story(story_id)).id).to eq 98
  end
end

