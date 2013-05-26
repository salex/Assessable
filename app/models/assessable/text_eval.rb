module Assessable  
  module TextEval
    
    class Numeric
      attr_reader :sections, :match, :deltas
      
      def initialize(text)
        @sections = text.split("::")
        @match = @sections[0].to_f 
        @deltas = {} # 0.0 => 100.0
        if @sections.length > 1
          1.upto(@sections.length - 1) do |i|
            t = @sections[i].split("%%")
            if t.length == 2
              @deltas[t[0].to_f] = t[1].to_f
            else
              @deltas[t[0].to_f] = 100.0
            end
          end
        end
      end
      
      
      def score(answer,value)
        ans = answer.to_f
        result = 0.0
        if @deltas.empty?
          @deltas = {0.0 => 100.0}
        end
        @deltas.each do |delta,percent|
          test_max = (@match + delta)
          test_min = (@match - delta)
          if ans.between?(test_min,test_max)
            result = value * (percent/100.0)
            break
          end
        end
        
        result = result < 0 ? 0 : result
        result = result > value ? value : result
        return result
      end
    end

    class Contains
      attr_reader :sections, :match, :or_groups, :partials
      
      def initialize(text)
        @sections = text.split("::")
        @match = @sections[0] ||= ""
        @or_groups = @match.split("||")
        @partials = []
        if @sections.length > 1
          1.upto(@sections.length - 1) do |i|
            t = @sections[i].split("%%")
            if t.length == 2
              @partials << [t[0],t[1].to_f]
            else
              @partials << [t[0],100.0]
            end
          end
        end
      end
      
      def format_form
        result = {"groups" => [], "partials" => []}
        @partials.each do |p|
          words = p[0]
          r = {"percent" => p[1]}
          r["not"] = words[0..0] == "!"
          words = words[1..-1] if r["not"] 
          r["or"] = words[0..0] == "("
          words = words[1..-2].gsub("|"," ") if r["or"]
          r["words"] = words
          result["partials"] << r
        end
        result["partials"] << {"percent"=>"", "not"=>false, "or"=>false, "words"=>""}
        @or_groups.each do |og|
          g = []
          match_ands = og.split('&')
          match_ands.each do |a|
            words = a
            r = {}
            r["not"] = words[0..0] == "!"
            words = words[1..-1] if r["not"] 
            r["or"] = words[0..0] == "("
            words = words[1..-2].gsub("|"," ") if r["or"]
            r["words"] = words
            g << r
          end
          result["groups"] << (g << {"not"=>false, "or"=>false, "words"=>""})
          
        end
        return result
      end
      
      def score(answer,value)
        return [exact_score(answer,value),partial_score(answer,value)].max
      end
  
      #private
  
      def and_splits(section)
        ands = section.split("&")
      end
  
      def exact_score(answer,value)
        ok = false
        @or_groups.each do |elem|
          is_there = match_exact(elem,answer)
          ok = ok || is_there
        end
        return ok ? value : 0.0
      end
      
      def match_exact(elem,answer)
        ands =  and_splits(elem)
        ok = true
        ands.each do |elem|
          eq = true
          if (elem[0..0] == "!") 
            eq = false
            elem = elem[1..-1]
          end
          if ok
            re = Regexp.new(elem,true)
            elem_ok = !( re =~ answer).nil? # it is there or not
            elem_ok = eq ? elem_ok : !elem_ok
            ok = ok && elem_ok
          end
        end
        return ok
      end  
      
      def partial_score(answer,value)
        result = 0.0
        return result if @partials.nil?
        @partials.each do |partial|
          if match_exact(partial[0],answer)
            result += value * (partial[1]/100.0)
          end
        end
        result = result < 0 ? 0 : result
        result = result > value ? value : result
        return result
        
      end
      
      #"!golf|hunt|fish"
      #3.1416::0.0>>100::2.5e-05>>100.0::0.0001>>80.0::0.001>>20.0
      #(quick|brown|lazy)&fox&back&!(the|jump|dog)::(quick|brown|lazy)>>20&fox>>40&back>>40&dog>>-50&the>>-75
      #(quick|brown|lazy)&fox&back&!(the|jump|dog)::(quick|brown|lazy)%%20::fox%%40::back%%40::dog%%-50::the%%-75
    end
  end
end