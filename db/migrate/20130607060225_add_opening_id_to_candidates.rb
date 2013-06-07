class AddOpeningIdToCandidates < ActiveRecord::Migration
  def up
    add_column :candidates, :current_opening_id, :integer, :default => -1
    Candidate.active.find_each do |candidate|
      opening_candidate = OpeningCandidate.where(:candidate_id => candidate.id).last
      candidate.current_opening_id = opening_candidate.opening_id if opening_candidate and !opening_candidate.opening.closed?
    end
  end

  def down
    remove_column :candidates, :current_opening_id
  end
end
