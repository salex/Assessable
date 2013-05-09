module Assessable
    
  class Assessing
        
    def self.get_post(id, session)
      stash = Stash.get(session)
      post = stash.get_post(id) 
    end
    
    class Display
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::FormTagHelper
      include Assessable::AssessmentsHelper
      
      def assessment(published_assessment,post=nil)
        render_assessment(published_assessment,post)
      end
    end
    
    def self.set_post(id,post,session)
      stash = Stash.get(session)
      stash.set_post(id,post)
    end
    
    def self.get_stash(session)
      stash = Stash.get(session)
    end
    
    def display_assessment(published_assessment,post=nil)
      render_assessment(published_assessment,post)
    end
    
    def self.clear_stash(session)
      Stash.clear(session)
    end
    
    def self.clone_assessment(id)
      assessment = self.find(id)
      return nil if assessment.nil?
      cloned_assessment = assessment.dup
      cloned_assessment.status = 'new'
      cloned_assessment.key = ''
      cloned_assessment.save
      new_assessment_id = cloned_assessment.id
      for question in assessment.questions
        answers = question.answers
        new_ques = question.dup
        new_ques.assessment_id = new_assessment_id
        new_ques.save
        new_quesid = new_ques.id
        for answer in answers
          new_ans = answer.dup
          new_ans.question_id = new_quesid
          new_ans.save
        end
      end
      return cloned_assessment
    end
    
    def self.get_published(assessment_id)
      assessment = Assessable::Assessment.find(assessment_id)
      return assessment.publish
    end  
    
    
    def self.score_assessment(assessment_hash,post)
      totalScore = 0
      totalScoreWeighted = 0
      post["scores"] = {"max" => {"raw" => assessment_hash["max_raw"].round(3), "weighted" => assessment_hash["max_weighted"].round(3)}}
      assessment_hash["questions"].each do |question|
        sum = 0
        max = -1 # allow for a 0 value
        qid = question["id"].to_s
        answered = post["answer"][qid]
        a_ids = question["answers"].collect{|i| i["id"].to_s}        
        score_method = question["score_method"].downcase
        if score_method != "none"
          txt_idx = 0
          question["answers"].each do |answer|
            aid = answer["id"].to_s
            if !answered.nil? && !answered.index(aid).nil?
              case score_method
              when "textcontains"
                answer = question["answers"][a_ids.index(answered[txt_idx])]
                te = Assessable::TextEval::Contains.new(answer["text_eval"])
                aval =  te.score(post["text"][answered[txt_idx]],answer["value"])
                sum += aval
              when "textnumeric"
                answer = question["answers"][a_ids.index(answered[txt_idx])]
                ne = Assessable::TextEval::Numeric.new(answer["text_eval"])
                aval = ne.score(post["text"][answered[txt_idx]],answer["value"])
                sum += aval
              else
                sum += answer["value"] ||= 0
                max = answer["value"] if answer["value"] > max
              end
            end
            txt_idx += 1
          end          
          case score_method
          when "sum"
            value = sum
          when "textcontains"
            value = sum
          when "textnumeric"
            value = sum
          else
            value = max
          end
          # if critical add qid to a critical array
          if question["critical"]
            if value < question["min_critical"]
              post['critical']  = [] unless post['critical']
              post['critical'] << qid
            end
          end
        else
          value = 0  
        end
        #logger.info "VALUE #{value} Total #{totalScore} Score Method #{score_method} Max #{max}"
        totalScore +=  value
        totalScoreWeighted += (value * question["weight"])
        post["scores"][qid] = {'raw'  => value, 'weighted'  => (value * question["weight"])}
        #puts "Totals #{totalScore} #{totalScoreWeighted}"
      end
      post["scores"]["total"] = {'raw'  => totalScore, 'weighted'  => totalScoreWeighted}
      post["scores"]["percent"] = {'raw'  => ( assessment_hash["max_raw"] == 0.0 ? 0.0 : (totalScore / assessment_hash["max_raw"]).round(3)) , 
        'weighted'  => (assessment_hash["max_weighted"] == 0.0 ? 0.0 : (totalScoreWeighted / assessment_hash["max_weighted"]).round(3))}
      all = []
      post["answer"].each do |key,value|
        all.concat(value)
      end
      post["all"] = all
      return  post

    end
  end
end

