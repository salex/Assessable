module AssessorsHelper
  
  def section_links(info)
    links = ""
     finished = true
     info["names"].each_index do |i| 
       links << "<li>"
       links << check_box("one",nil, :checked => info["status"][i])  
       links << link_to( info["names"][i], section_take_path("#{i}back"))
       links << '</li>'
       finished = finished && info["status"][i]
     end 
     if finished 
       links << "<li>"
       links << check_box("one",nil, :checked => finished )
       links << link_to( "Finish", complete_take_path("complete"))
       links << '</li>'
     end 
    return links.html_safe
  end
  
end
