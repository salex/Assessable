# TTTTTTTTTTTTTTTTTTT Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.


$(document).ready ->

  $(document).on("click", '[data-behavior="edit_contains"]', -> 
    $("#"+this.id+"_div").toggle())

  $(document).on("click",'[data-behavior="edit_numeric"]', -> 
    $("#"+this.id+"_div").toggle())

  $(document).on("click", '[data-behavior="contains_cancel"]',->
    seq = get_seq(this.id)
    $("#eval_"+seq+"_div").hide())

  $(document).on("click", '[data-behavior="numeric_cancel"]', ->
    seq = get_seq(this.id)
    $("#eval_"+seq+"_div").hide())

  $(document).on("click",'[data-behavior="contains_update"]', ->
    update_contains(this.id))
      
  $(document).on("click",'[data-behavior="numeric_update"]', ->
    update_numeric(this.id))

  update_contains = (id) ->
    key = get_seq_base(id)
    matchKey = key + "_match"
    partialKey = key + "_partial"
    matches = $("."+ matchKey)
    partials = $("."+partialKey)
    match_section = format_match(matches)
    partial_section = format_partial(partials)
    
    seq = get_seq(id)
    text_eval = "#question_answers_attributes_#{seq - 1}_text_eval"
    if partial_section == ""
      $(text_eval).val(match_section)
    else
      $(text_eval).val(match_section+"::"+partial_section)
    $("#eval_"+seq+"_div").hide()
    $(text_eval).css("color","orange")
    
    
     
  format_match = (matches) ->
    result = new Array()
    for match in matches
      if match.value != ""
        value = match.value
        id = match.id
        or_id = id.replace("match", "word_or")
        not_id = id.replace("match", "word_not")
        gor_id = id.replace("match", "group_or")
        x = $("#"+or_id).prop('checked')
        y = $("#"+not_id).prop('checked')
        z = $("#"+gor_id).prop('checked')
        #alert("#{z} #{x} #{y} #{value} #{gor_id}")
        if x
          if value.indexOf("|") < 0
            value = value.replace( /\s+/g, ' ' )
            tmp = value.split(" ");
            value = "(" + tmp.join("|") + ")"
          else
            value = "(" + value + ")"
            
        if y
          value = "!" + value
        if z
          value = "||" + value
          
        result.push(value)
    section = result.join("&").replace("&||","||")
    
    return(section)
    
  format_partial = (partials) ->
    result = new Array()
    for partial in partials
      if partial.value != ""
        value = partial.value
        id = partial.id
        or_id = id.replace("partial_match", "partial_or")
        not_id = id.replace("partial_match", "partial_not")
        perc_id = id.replace("partial_match", "partial_percent")
        x = $("#"+or_id).prop('checked')
        y = $("#"+not_id).prop('checked')
        perc = $("#"+perc_id).val()
        if perc == "" then perc = 0
        if x
          if value.indexOf("|") < 0
            value = value.replace( /\s+/g, ' ' )
            tmp = value.split(" ");
            value = "(" + tmp.join("|") + ")"
          else
            value = "(" + value + ")"
        if y
          value = "!" + value
        value += "%%#{perc}"
        result.push(value)
    return(result.join("::"))
    

  update_numeric = (id) ->
    seq = get_seq(id)
    matchKey = "#numeric_match_"+seq
    match = $(matchKey)
    nvalue = match.val()  
    key = get_seq_base(id)
    deltaKey = key + "_delta"
    deltas = $("."+ deltaKey)
    result = new Array()
    for delta in deltas
      if delta.value != ""
        value = delta.value
        delta_id = delta.id
        perc_id = delta_id.replace("delta", "percent")
        perc = $("#"+perc_id).val()
        if perc == "" then perc = 100
        value += "%%#{perc}"
        result.push(value)    
    delta_section = result.join("::")
    text_eval = "#question_answers_attributes_#{seq - 1}_text_eval"
    if delta_section == ""
      $(text_eval).val(nvalue)
    else
      $(text_eval).val(nvalue+"::"+delta_section)
    $("#eval_"+seq+"_div").hide()
    $(text_eval).css("color","orange")
    

  get_seq = (id) ->
    t = id.split("_")
    return t[1]

  get_seq_base = (id) ->
    t = id.split("_")
    return t[0]+"_"+t[1]


