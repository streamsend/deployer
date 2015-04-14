require "spec_helper"
require_relative "../../lib/release"

describe Release do
  let(:release) { Release.new("../streamsend-root/streamsend", "HEAD^") }

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
end
