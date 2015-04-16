require "spec_helper"
require_relative "../../lib/release"

describe Release do
  let(:release) { Release.new("../streamsend-root/streamsend", "HEAD^") }
  let(:commits) { [{commit_id: 12345, line: "some commit"}, {commit_id: 23456, line: "radiant commit"}] }

  describe "#commits" do
    it "returns the commits" do
      expect(release.commits.size).to eq 1
    end
  end

  describe "#stories_from_commits" do
    it "returns the stories from commits" do
      expect(release.stories_from_commits(release.commits)).to be_a Hash
    end
  end

  describe "#story_from_commit" do
    it "returns the story id from the commit" do
      expect(release.story_from_commit("758182d")).to eq "bug fix"
    end

    it "returns none if no story" do
      expect(release.story_from_commit("3111b33")).to eq "None"
    end
  end

  describe "#describe_commits_list" do
    it "returns a list of commits" do
      expect(release.describe_commits_list(commits)).to eq "\n       * #{commits[0][:line]}\n       * #{commits[1][:line]}"
    end
  end

  describe "#describe_commits_brief" do
    it "returns a list of commits" do
      expect(release.describe_commits_brief(commits)).to eq "      * commits: #{commits[0][:commit_id]},#{commits[1][:commit_id]}"
    end
  end

  describe "#git_latest_tag" do
    it "returns a tag version" do
      expect(release.git_latest_tag).to match(/^v[0-9]\.[0-9\.]*/)
    end
  end
end
