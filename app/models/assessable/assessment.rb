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
    
    def compute_max_scores(published)
      max_raw = max_weighted = 0
      published['questions'].each do |question|
        answer_values = question['answers'].map{|i| i['value']}
        score_method = question['score_method'].downcase
        unless score_method == 'none'
          if score_method == 'sum' || score_method.include?('text')
            value = answer_values.sum
          else
            value = answer_values.max
          end
          max_raw += value
          max_weighted += (value * question['weight'])
        end
      end
      if published["max_raw"] != max_raw || published["max_weighted"] != max_weighted
        published["max_raw"] = max_raw
        published["max_weighted"] = max_weighted
        self.updated_at = Time.now  # force commit
        self.save
      end
      return nil
    end
  
  
    def publish(tojson = false)
      #double parse to get rid of symbols from as_json hash
      hash = self.as_json(:except => [:created_at, :updated_at ], 
        :include => {:questions => {:except => [:created_at, :updated_at ],
        :include => {:answers => {:except => [:created_at, :updated_at ]}}}})
      json = hash.to_json
      hash = Assessable.safe_json_decode(json)
      self.compute_max_scores(hash) # saves assessment if max scores changed
      return tojson ? json : hash
    end
    
    def export
      #double parse to get rid of symbols from as_json hash
      hash = self.as_json(:except => [:created_at, :updated_at, :id ], 
        :include => {:questions => {:except => [:created_at, :updated_at,:id, :assessment_id ],
        :include => {:answers => {:except => [:created_at, :updated_at, :id, :question_id ]}}}})
      json = hash.to_json
      hash = Assessable.safe_json_decode(json)
      self.compute_max_scores(hash) # saves assessment if max scores changed
      return  hash
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
      new_assmnt.transaction do
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
  
  ## method only for testing (small version of published with only attr for testing), does not call compute max
  def score_hash(tojson = false)
    #double parse to get rid of symbols from as_json hash
    hash = self.as_json(:only => [:id, :max_raw, :max_weighted ], 
      :include => {:questions => {:only => [:id, :score_method, :weight, :critical, :min_critical ],
      :include => {:answers => {:only => [:id, :value, :text_eval ]}}}})
    json = hash.to_json
    hash = Assessable.safe_json_decode(json)
    return tojson ? json : hash
  end
  
end
