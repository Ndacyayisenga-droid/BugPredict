require "rugged"

module Bugspots
  Fix = Struct.new(:message, :date, :files)
  Spot = Struct.new(:file, :score)

  def self.scan(repo, branch = "openj", depth = nil, regex = nil)
    regex ||= /\b(fix(es|ed)?|close(s|d)?)\b/i
    fixes = []

    repo = Rugged::Repository.new(repo)
    unless repo.branches.each_name(:local).sort.find { |b| b == branch }
      raise ArgumentError, "no such branch in the repo: #{branch}"
    end

    walker = Rugged::Walker.new(repo)
    walker.sorting(Rugged::SORT_TOPO)
    walker.push(repo.branches[branch].target)
    walker = walker.take(depth) if depth
    walker.each do |commit|
      if commit.message.scrub =~ regex
        files = commit.diff(commit.parents.first).deltas.collect do |d|
          d.old_file[:path]
        end
        fixes << Fix.new(commit.message.scrub.split("\n").first, commit.time, files)
      end
    end

    # Return early if no fixes are found
    if fixes.empty?
      return [], [], {}
    end

    hotspots = Hash.new(0)
    commits = Hash.new([])
    currentTime = Time.now
    oldest_fix_date = fixes.last.date

    fixes.each do |fix|
      fix.files.each do |file|
        # The timestamp used in the equation is normalized from 0 to 1, where
        # 0 is the earliest point in the code base, and 1 is now (where now is
        # when the algorithm was run). Note that the score changes over time
        # with this algorithm due to the moving normalization; it's not meant
        # to provide some objective score, only provide a means of comparison
        # between one file and another at any one point in time
        t = 1 - ((currentTime - fix.date).to_f / (currentTime - oldest_fix_date))
        hotspots[file] += 1 / (1 + Math.exp((-12 * t) + 12))
        commits[file] += [{'message': fix.message, 'date': fix.date}]
      end
    end

    spots = hotspots.sort_by { |k, v| v }.reverse.collect do |spot|
      Spot.new(spot.first, sprintf('%.4f', spot.last))
    end

    return fixes, spots, commits
  end
end