module Assessable
  class Assessment < ActiveRecord::Base
    has_many :questions, :order => "sequence", :dependent => :destroy
    
    attr_accessible :category, :default_layout, :default_tag, :description, :instructions, :key, :max_raw, :max_weighted, :name, :status, :assessing_key
  
    def self.search(params)
      assessments = Assessable::Assessment.scoped

      params[:where] = "Contains" unless params[:where]
      params[:key] = "" unless params[:key]
      params[:status] = "" unless params[:status]
      case params[:where]
      when 'Start with'
       key =  params[:key] + "%"
      when 'Contains'
       key = "%" + params[:key] + "%"
      when "Ends with"
       key = "%" + params[:key]
      else
       key = params[:key]
      end
      # For psql, change LIKE to ILIKE or downcase everything
      ilike =  "category LIKE '#{key}' OR assessing_key LIKE '#{key}' OR name LIKE '#{key}' OR description LIKE '#{key}'"
      assessments = assessments.where(ilike)
      return assessments
    end
  
  
    def compute_max
      assessment = self
      maxRaw = 0
      maxWeighted = 0
      for question in assessment.questions
        maxQues = -1
        sumQues = 0
        weight = question.weight.nil? ? 0 : question.weight.to_f
        ansType = question.answer_tag.blank? ? "" : question.answer_tag.downcase
        scoreMethod = question.score_method.blank? ? "value" : question.score_method.downcase
        isScored = ((scoreMethod.downcase != "none") ) # and (weight > 0)
        isText =  !(ansType =~ /text/i).nil?
        for answer in question.answers
          isTextScored =  !answer.text_eval.blank? 
          value = answer.value.to_f
          if isScored
            if ((isText  and isTextScored) or (!isText ))
              if (value > maxQues)
                maxQues = value
              end if
              sumQues += value        
            end
          end
        end
        if ((scoreMethod == "sum")  and ((ansType == "checkbox") || (ansType == "select-multiple")))
          maxRaw += sumQues
          maxWeighted += (sumQues * weight)
        elsif ((scoreMethod == "textcontains") || (scoreMethod == "textnumeric"))
          maxRaw += sumQues
          maxWeighted += (sumQues * weight)
        else
          maxRaw += maxQues
          maxWeighted += (maxQues * weight)
        end
      end
      assessment.max_raw = maxRaw
      assessment.max_weighted = maxWeighted
      assessment.updated_at = Time.now  # force commit
      assessment.save
      return true
    end
  
    def publish(tojson = false)
      compute_max
      #double parse to get ride of dates from hash
      hash = self.as_json(:except => [:created_at, :updated_at ], 
        :include => {:questions => {:except => [:created_at, :updated_at ],
        :include => {:answers => {:except => [:created_at, :updated_at ]}}}})
      json = hash.to_json
      hash = Assessable.safe_json_decode(json)
      return tojson ? json : hash
    end
    
    def export
      compute_max
      #double parse to get ride of dates from hash
      hash = self.as_json(:except => [:created_at, :updated_at, :id ], 
        :include => {:questions => {:except => [:created_at, :updated_at,:id, :assessment_id ],
        :include => {:answers => {:except => [:created_at, :updated_at, :id, :question_id ]}}}})
      json = hash.to_json
      hash = Assessable.safe_json_decode(json)
      return  hash
    end
    
    
    def score_hash(tojson = false)
      #double parse to get ride of dates from hash
      hash = self.as_json(:only => [:id, :max_raw, :max_weighted ], 
        :include => {:questions => {:only => [:id, :score_method, :weight, :critical, :min_critical ],
        :include => {:answers => {:only => [:id, :value, :text_eval ]}}}})
      json = hash.to_json
      hash = Assessable.safe_json_decode(json)
      return tojson ? json : hash
    end
    

    def self.publish(assessment_id)
      assessment = self.find(assessment_id)
      return assessment.publish
    end  
    
    def clone
      cloned_assessment = self.dup
      cloned_assessment.status = 'new'
      cloned_assessment.key = ''
      cloned_assessment.name = "Cloned #{cloned_assessment.name}"
      cloned_assessment.save
      newassid = cloned_assessment.id
      for question in self.questions
        answers = question.answers
        newques = question.dup
        newques.assessment_id = newassid
        newques.save
        newquesid = newques.id
        for answer in answers
          newans = answer.dup
          newans.question_id = newquesid
          newans.save
        end
      end
      return cloned_assessment
    end
  
    def self.import_hash(assmnt)
      questions = assmnt["questions"]
      assmnt.delete("questions")
      new_assmnt = self.new(assmnt)
      new_assmnt.save
      questions.each do |question|
        answers = question["answers"]
        question.delete("answers")
        new_question = new_assmnt.questions.build(question)
        new_question.save
        answers.each do |answer|
          new_answer = new_question.answers.build(answer)
          new_answer.save
        end
      end
    end
  end
  
end
