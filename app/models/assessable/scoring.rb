module Assessable
  module Scoring
 
    class Score
      attr_reader   :post, :scores, :all_answers
      def initialize(assessment,post)
        #@assessment = assessment
        @post = post
        @all_answers = @post["answer"].values.flatten
        @total_raw = @total_weighted = 0
        @scores = {"max" => {"raw" => assessment["max_raw"].round(3), "weighted" => assessment["max_weighted"].round(3)}}
        score_questions(assessment)
      end
      
      def scored_post
        post = self.post
        post["scores"] = self.scores
        return post
      end
      
      private
      
      def score_questions(assessment)
        assessment["questions"].each do |question|
          score_question(question)
        end
        @scores["total"] = {'raw'  => @total_raw, 'weighted'  => @total_weighted}
        @scores["percent"] = {'raw'  => to_percent(@total_raw, @scores["max"]["raw"]) , 'weighted'  => to_percent(@total_weighted, @scores["max"]["weighted"])}
        return self
      end
      
      def score_question(question)
        qkey = question["id"].to_s
        answered = @post["answer"][qkey]
        # return if question is not answered in post (question not required and not answered)
        return if answered.nil? || answered.empty?
        @score_method = question["score_method"].downcase
        case @score_method
        when 'none'
          # return if question is answered in post but not scored
          return
        when 'textcontains'
          score_text_contains(question,answered)
        when 'textnumeric'
          score_text_numeric(question,answered)
        else
          score_value(question,answered)
        end
      end
      
      
      def get_answer_keys(question)
        a_keys = question["answers"].collect{|i| i["id"].to_s}        
      end
      
      def to_percent(total,max)
        return 0.0 if max.zero?
        percent = (total / max).round(3)
      end
      
      def score_text_contains(question,answered)
        a_keys = get_answer_keys(question)
        txt_idx = 0
        sum = 0
        question["answers"].each do |answer|
          answer = question["answers"][a_keys.index(answered[txt_idx])]
          texteval = Assessable::TextEval::Contains.new(answer["text_eval"])
          value =  texteval.score(@post["text"][answered[txt_idx]],answer["value"])
          sum += value
          txt_idx += 1
        end
        set_score(question,sum)
      end
      
      def score_text_numeric(question,answered)
        a_keys = get_answer_keys(question)
        txt_idx = 0
        sum = 0
        question["answers"].each do |answer|
          answer = question["answers"][a_keys.index(answered[txt_idx])]
          texteval = Assessable::TextEval::Numeric.new(answer["text_eval"])
          value =  texteval.score(@post["text"][answered[txt_idx]],answer["value"])
          sum += value
          txt_idx += 1
        end
        set_score(question,sum)
      end
      
      def score_value(question,answered)
        sum = 0
        max = -1 # allow for a 0 value
        question["answers"].each do |answer|
          akey = answer["id"].to_s
          unless answered.index(akey).nil?
            sum += answer["value"] ||= 0
            max = answer["value"] if answer["value"] > max
          end
        end
        value = @score_method == 'sum' ? sum : max
        set_score(question,value)
      end

      def set_score(question,value)
        qkey = question["id"].to_s
        @total_raw +=  value
        @total_weighted += (value * question["weight"])
        @scores[qkey] = {'raw'  => value, 'weighted'  => (value * question["weight"])}
        # if critical add qid to a critical array
        if question["critical"]
          if value < question["min_critical"]
            @scores['critical']  = [] unless @scores['critical']
            @scores['critical'] << qkey
          end
        end
      end
    end
    
  end
end

=begin

"post"=>{"answer"=>{"1"=>["1"], "2"=>["12"]}}

{"id"=>1, "max_raw"=>4.0, "max_weighted"=>4.0, "questions"=>[{"critical"=>true, "id"=>1, "min_critical"=>1.0, "score_method"=>"Value", "weight"=>1.0, 
"answers"=>[{"id"=>1, "text_eval"=>nil, "value"=>0.0}, {"id"=>2, "text_eval"=>nil, "value"=>1.0}, {"id"=>3, "text_eval"=>nil, "value"=>2.0}]}, 
{"critical"=>false, "id"=>2, "min_critical"=>nil, "score_method"=>"Value", "weight"=>1.0, 
"answers"=>[{"id"=>11, "text_eval"=>nil, "value"=>0.0}, {"id"=>12, "text_eval"=>nil, "value"=>1.0}, {"id"=>13, "text_eval"=>nil, "value"=>2.0}]}]}

=end