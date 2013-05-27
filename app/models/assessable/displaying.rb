module Assessable
  module Displaying
    
    class Display
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::FormTagHelper
      
      attr_reader  :html
      def initialize(published_assessment,post=nil)
        @assessment = published_assessment
        @post = post
        @all_answers = @post["answer"].values.flatten if @post
        @html = render_assessment
      end
      
      def self.assessment(published_assessment,post=nil)
        obj = self.new(published_assessment,post)
        return obj.html
      end

      
      private
      
      def render_assessment
        questions = render_questions
        content_tag :div, (render_instructions + questions), class: "take-assessment", id: "take_assessment"
      end
      
      def render_instructions
        content_tag :fieldset, (content_tag(:legend,"Instructions") + @assessment["instructions"]).html_safe, class: "take-instructions"
      end
      
      def render_questions
        questions = ""
        @assessment['questions'].each do |q|
          @answer_layout =  q["answer_layout"].downcase
          @score_method =  q["score_method"].downcase
          @answer_tag = q["answer_tag"].downcase 
          unless @answer_layout  == "none"
            questions += render_group(q)
            questions += render_question_instructions(q)
            # question requires_other set in question hash if any answer requires other
            q["answers"].map{|r| q["requires_other"] = r["requires_other"] if r["requires_other"]  }
            if @answer_layout  == "inline"
              questions += render_inline(q)
            else
              questions += render_list(q)
            end
          end
        end
        content_tag :div, questions.html_safe, class: "take-questions"
      end
      
      def render_group(q)
        return "" if q["group_header"].blank?
        content_tag :div, q['group_header'], class: "take-group-header"
      end

      def render_question_instructions(q)
        return "" if q["instructions"].blank?
         content_tag :div, q['instructions'], class: "take-question-instructions"
      end
      
      def render_inline(q)
        if !(q["answer_tag"] =~   /select/i).nil?
          itag, others = render_select_tag(q)
          answers = content_tag :span, itag, class: "take-select"
        else
          others = ""
          answers = ""
          q['answers'].each do |a|
            if a['requires_other']
              others += render_other(a) 
            end
            itag = render_input(q,a) + a['answer_text']
            answers += content_tag :span, itag, id: "take_answer_#{a['id']}", class: "take-inline-answer"
          end
        end
        content_tag :div, (table_list(answers,render_question_text(q)) + others.html_safe).html_safe, id: "take_question_#{q['id']}", class: 'take-question'
      end

      def render_list(q)
        if !(q["answer_tag"] =~   /select/i).nil?
          itag, others = render_select_tag(q)
          answers = content_tag :span, itag, class: "take-select"
          tbl = table_list(answers, others.html_safe).html_safe
          content_tag :div, (render_question_text(q) + tbl.html_safe).html_safe, id: "take_question_#{q['id']}", class: 'take-question'
        else
          answers = ""
          q['answers'].each do |a|
            other = a['requires_other'] ? render_other(a) : ""
            itag = render_input(q,a)
            answers += wrap_row(itag,a['answer_text']+other).html_safe
          end
          content_tag :div, (render_question_text(q) + content_tag(:table,answers.html_safe, class: "take-list")).html_safe, id: "take_question_#{q['id']}", class: 'take-question'
        end
      end
      
      def render_select_tag(q)
        # it returns a select tag, with all options set and other divs, if any
        others = ""
        answers = q["answers"]
        options = ""
        answers.each do |answer|
          if answer['requires_other']
            others += render_other(answer) 
          end

          text, exists, other = get_post_answer(answer)

          sel = exists ? 'selected="selected"' : ""        
          options << "<option value=\"#{answer["id"]}\" #{sel}>#{answer["answer_text"]}</option>"

        end
        data_behavior = q["requires_other"] ? "toggle_other_sel" : ""
        mult = @answer_tag == "select" ? false : true
        required = @score_method == "none" ? "" : "required-one"

        itag = select_tag("post[answer][#{q["id"]}][]", options.html_safe, :id => "qa_#{q["id"]}", 
        :class => required, :include_blank => !mult, :multiple => mult, :"data-behavior" => data_behavior )
        return itag, others
      end
      
      def render_other(a)
        # it needs to build a text input for other question, including @post
        text, exists, other = get_post_answer(a)
        dsp = exists ? "block" : "none"

        tag = text_field_tag("post[other][#{a["id"].to_s}]",other, :id => "text_qa_#{a["question_id"]}_#{a["id"]}", :disabled => !exists)
        content_tag( :div, 
          (tag + a["answer_text"] + ":" + a["other_question"]).html_safe, 
          class: "take-other-question", id: "other_qa_#{a["question_id"]}_#{a["id"]}",style: "display:#{dsp}")
      end

      def render_question_text(q)
        content_tag :span, q['question_text'].html_safe, class: "take-question-text"
      end
      
      def table_list(c1,c2)
        "<table><tr><td>#{c1}</td><td>#{c2}</td></tr></table>".html_safe
      end

      def wrap_row(c1,c2)
        "<tr><td>#{c1}</td><td>#{c2}</td></tr>".html_safe
      end

      def get_post_answer(a)
        answer_id = a['id'].to_s
        text = ""
        exists = false
        other = ""
        if @post
          #Answers from a previous application or session are in the Params collection - values are extracted
          #into the variables exist, other, and text 
          if !@all_answers.index(answer_id).nil?
            exists = true
            other = @post["other"][answer_id] if @post["other"]
            text = @post["text"][answer_id] if @post["text"]
          end
        end
        return text, exists, other
      end


      def render_input(question,answer)
        # until this point, we don't know what the input tag is
        # it creates input tag
        result = ""
        text, exists, other =  get_post_answer(answer)
        case @answer_tag
        when "radio"
          required = @score_method == "none" ? "" : "required-one"
          behavior = question["requires_other"] ? "toggle_other" : ""
          result = radio_button_tag("post[answer][#{question["id"]}][]",answer["id"].to_s, exists,
           :class => required, :"data-behavior" => behavior , :id => "qa_#{question["id"]}_#{answer["id"]}")
        when "checkbox"
          required = @score_method == "none" ? "" : "required-one"
          behavior = answer["requires_other"] ? "toggle_other" : "none"
          result = check_box_tag("post[answer][#{question["id"]}][]",answer["id"].to_s, exists,
           :class => required, :"data-behavior" => behavior, :id => "qa_#{question["id"]}_#{answer["id"]}")
        when "textarea"
          required = @score_method == "none" ? "" : "required"
          hidden_elem = hidden_field_tag("post[answer][#{question["id"]}][]",answer["id"].to_s,:id => nil ) 
          result = hidden_elem + text_area_tag("post[text][#{answer["id"]}]",text,
           :class => required,  :id => "qa_#{question["id"]}_#{answer["id"]}")
        when /text/i
          required = @score_method == "none" ? "" : "required"
          hidden_elem = hidden_field_tag("post[answer][#{question["id"]}][]",answer["id"].to_s,:id => nil ) 
          result = hidden_elem + text_field_tag("post[text][#{answer["id"]}]",text,
           :class => required,  :id => "qa_#{question["id"]}_#{answer["id"]}")
        end
        return result 
      end
    end
    
    def self.display_summary(assmt,post)

      html = ""
      alt = true 
      ans_count = post['answer'].count
      assmt['questions'].each do |question|
        alt = !alt
        rclass = alt ? 'alt' : ''
        qkey = question['id'].to_s
        ans_array = question['answers'].map{|i| i['id']}
        ans = post['answer'][qkey]
        next if ans.nil?
        all = "["
        isText =  !(question['answer_tag'] =~ /text/i).nil?
        question_text = question['short_name'].blank? ? question['question_text'].slice(0,40) : question['short_name']
        question_text = "{#{question["id"]}} #{question_text}"
        answer_text = ""
        ans.each do |akey|
          akeyi = akey.to_i
          aidx = ans_array.index(akeyi)
          answ = question['answers'][aidx]
          answer_text = answ['short_name'].blank? ? answ['answer_text'].slice(0,20) : answ['short_name']
          if isText
            all << post['text'][akey] + ", " unless post['text'][akey].nil?
          else
            if answ['requires_other'] && post['other']
              all << answer_text + '{' + post['other'][akey] + '}, '
            else
              all << answer_text + ", "
            end
          end
        end
        all = all[0..-3] + "]"
        if post['scores']['critical']
          rclass = post['scores']['critical'].index(qkey).nil? ? rclass : (rclass += " failed"  )
        end
        rclass = "class=\"#{rclass}\"" unless rclass.blank?

        html << "<tr #{rclass}><td>#{question_text}</td><td>#{all}</td><td>#{post['scores'][qkey]['raw']}</td><td>#{post['scores'][qkey]['weighted']}</td></tr>"
      end
      html << "<tr class=\"list-header\"><td></td><td>Total</td><td>#{post['scores']["total"]['raw']}</td><td>#{post['scores']["total"]['weighted']}</td></tr>"
      
      return html.html_safe
    end  
    
  end
end
