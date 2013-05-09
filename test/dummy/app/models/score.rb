class Score < ActiveRecord::Base
  attr_accessible :answers, :assessed_id, :assessed_type, :assessor_section_id, :category, :raw, :scoring, :status, :weighted
  belongs_to :assessed, :polymorphic => true
  belongs_to :assessor_section
  serialize :scoring, JSON
  
  def self.post_scores(stash)
    taking = stash.session["taking"]
    posts = stash.data["post"]
    sections = taking["sections"]
    a_type = taking["assessed_type"].constantize
    a_id = taking["assessed_id"]
    assessed = a_type.where(:id => a_id).first
    sections.each do |section|
      score = assessed.scores.where(:assessor_section_id => section).first
      unless score
        score = Score.new(:assessor_section_id => section)
        score.assessed = assessed
      end
      score.scoring = posts[section.to_s]
      score.category = AssessorSection.find(section).category
      score.raw = score.scoring["scores"]["percent"]["raw"]
      score.weighted = score.scoring["scores"]["percent"]["weighted"]
      score.answers = "|"
      score.scoring["all"].each do |v|
        score.answers += (v.to_i).to_s + "|"
      end
      if score.scoring["critical"].nil?
        score.status = "Passed"
      else
        score.status = "Failed"
      end
      score.save
    end
  end
  
  def self.post_survey(stash)
    taking = stash.session["taking"]
    posts = stash.data["post"]
    sections = taking["sections"]
    smax = taking["max"]
    a_type = taking["assessed_type"].constantize
    a_id = taking["assessed_id"]
    assessed = a_type.where(:id => a_id).first
    lcv = 0
    sections.each do |section|
      score = assessed.scores.where(:assessor_section_id => section).first
      unless score
        score = Score.new(:assessor_section_id => section)
        score.assessed = assessed
        score.scoring = {"count" => 0, "questions" => {},"all" => []}
      end
      post = posts[section.to_s]
      s = score.scoring
      s["count"] += 1

      post["answer"].each do |k,v|
        if s["questions"][k].nil?
          s["questions"][k] = {"answers" => {},"score" => 0}
        end
        s["questions"][k]["score"] += post["scores"][k]["raw"]
        v.each do |a|
          if s["questions"][k]["answers"][a].nil?
            s["questions"][k]["answers"][a] = 0
          end
          s["questions"][k]["answers"][a] += 1
        end
      end
      max = s["count"] * smax[lcv]
      total = 0.0
      s["questions"].each do |q,v|
        total += v["score"]
      end
      
      score.status = "Count:#{s["count"]}"
      score.raw = (total / max).round(3)
      score.category = AssessorSection.find(section).category
      score.scoring = s
    
      score.save
      lcv += 1
    end
  end
  
end
