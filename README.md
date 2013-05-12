# Assessable

Rails 3 engine that helps manage developing, administering and scoring assessments, quizzes, evaluations, surveys, etc

*Note: this is a re-factoring of another repository named Take. My goal was TDD, but I failed:-(*

### Dictionary Definitions

    assessment |əˈsesmənt|
    noun
    the evaluation or estimation of the nature, quality, or ability of someone or something : the assessment of educational needs | he made a rapid assessment of the situation | assessments of market value.
    
    assess |əˈses|
    verb [ trans. ]
    evaluate or estimate the nature, ability, or quality of : the committee must assess the relative importance of the issues | [with clause ] it is difficult to assess whether this is a new trend.
    • (usu. be assessed) calculate or estimate the price or value of : the damage was assessed at $5 billion.
    • (often be assessed) set the value of a tax, fine, etc., for (a person or property) at a specified level : all empty properties will be assessed at 50 percent.
    
    DERIVATIVES
    assessable adjective
    ORIGIN late Middle English : from Old French assesser, based on Latin assidere ‘sit by’ (in medieval Latin ‘levy tax’ ), from ad- ‘to, at’ + sedere ‘sit.’ Compare with assize .

There are a number of gems/engines that provide similar functionality. Most are targeted to a specific applications, e.g., Surveys.
That targeting usually requires you to adhere to the gems **solution**. How things are formatted, where the results are stored, etc. is controlled
by the gem.

Assessable takes a different approach in that the engine only provides limited **solutions**. It only provides three functions:

* CRUD management of the Assessments<-Questions<-Answers nested structure.
  * This is not much more than a slightly styled and altered scaffold structure of nested models.
* A helper that formats the Assessments<-Questions<-Answers into form inputs that you wrap into a form in your application.
  * An Assessment model instance method *publish* generates a hash that represents the nested structure. That hash is used
  in the helper and in the next function, scoring.
  * Form elements include, Radio Buttons, Check Boxes, Text Fields, Textareas, Select tags, Multiple-Select Tags
* A method to score the results given the published hash, and the post results (params[:post]) from the form.
  * The method returns a score object that adds scores and other information to the form post params.
  * Scoring is computed from the value of each answer. The sum of all the answer values is compared to the **maximum** score possible.
  * Scoring is optional, you can just gather the answers and do your own evaluation/mining/scoring.
  
Because of this approach, your application controls the **Taking** process and the **Storing** process. While this requires more work on your part, you are not 
strapped to someones vision on how your application should operate.

## Suggestion

Before you decide to include this as a gem/engine in your application, I suggest that you clone to repository and run the dummy application.

The dummy applications has examples on the **usage** of the engines functions to assess:

* Quizzes/Applications - Assessable has it roots in asking questions centered around an on-line job application.
* Survey - Anonymous surveys
* Evaluations - Modified survey to evaluate performance or person or process
* Progressions - Modified quizzes that score performance of an applicant in training (followup evaluations after application).

The examples will be documented on the WIKIE

## Installation

Add Assessable to your Gemfile:

    gem 'assessable', :git => 'git://github.com/salex/Assessable.git'

Then run:

    bundle install
    rake assessable:install:migrations
    rake db:migrate

Add Assessable to your config/routes.rb:

    mount Assessable::Engine, :at => 'assessable'

Install minimal CSS, JS and helpers

    rails g assessable:install
  
Optionally install the full helper if you wish to customize the formatting of the form input elements.

    rails g assessable:helper

## Usage

### Create Some Assessments, Questions and Answers

All models have a number of optional application defined fields that allow liking to your application and formatting the assessment. The Assessment
show view has a Display/Test link that renders a form with the questions and answers. Answering the questions and submitting the form will present the 
results of the scoring. This will allow you to evaluate if the Assessable approach fits your needs. If you need a more in-depth analysis, follow the suggestion and 
look at the Dummy application.

If your are creating Assessments that the answers are repetitive (rate on a 1 to 5 scale), Questions can be cloned, 
requiring that you only have to provide the questions text.

The major fields in each model are presented below with some comments on there usage/purpose.

* Assessments - Really just pointer to Questions and Answers
  * string   "name" - Application defined
  * string   "category" - Application defined - used in Dummy display 
  * string   "description" - Application defined
  * string   "instructions" - If present, displayed at top of assessment display
  * string   "key" - Application defined (roots in transitioning an older application)
  * string   "default_tag" - If present, Questions will use the tag (radio, checkbox, etc)
  * string   "default_layout" - If present, Questions will use the layout (list, inline, none)
  * float    "max_raw" - Computed sum of all answer values when Assessment Published
  * float    "max_weighted" - Computed sum of all answer values if question is weighted
  * string   "status" - Application defined
  * string   "assessing_key" - Application defined
  
* Questions 
  * integer  "sequence" - Controls order in which Questions are asked
  * string   "question_text" - The Question
  * string   "short_name" - Optional short name of question. For use if a summary report is generated.
  * string   "instructions" - If present, displayed before the question
  * string   "group_header" - If present, displayed before the question. e.g, "Rate following on a 1-5 scale"
  * string   "answer_tag" - Radio, Checkbox, Text, Textarea, Select, Select-Multiple
  * string   "answer_layout" - List, Inline
  * float    "weight" - Defaults to 1, optionally allows question to be weighted
  * boolean  "critical" - A question can be critical. If answer is below a minimum value, marked in scoring
  * float    "min_critical" - Required if critical is true and provides the minimum value.
  * string   "score_method" - Value (default), Sum and Max for checkboxes and multiple selects, None, Texteval - scores text
  * string   "key" - See assessment

* Answers
  * integer  "sequence" - Controls order in which Answers are displayed
  * string   "answer_text" - The Answer
  * string   "short_name" - Optional short name if answer is long
  * float    "value" - >= 0 value
  * boolean  "requires_other" - For all except text, asks for additional information if answer is selected
  * string   "other_question" - The question to ask for additional information
  * string   "text_eval" - Text can be scored and evaluated by a RegEx formula (helper provided)
  * string   "key" - See Assessment
 

There is also a Stash model that is basically on session store used to store intermediate results and help control the Taking function.

###  In your Application

Since Assessable only provides Crud, Displaying and Scoring, you must provide an interface and Taking and Storing functions. The dummy application
provides examples on how to accomplish this. While there are a number of approaches, they boil down to:

* An Assessor - model or models that link to the Assessable:Assessment in some way.
  * The Dummy app uses Assessor and AssessorSections that allow Assessments to have Sections - which contain the link.
* A Take controller(s) that gets the published Assessment, Displays it, and Scores is. (Taking)
  * An Assessing class is installed in your models/assessable directory that provides helper methods without namespacing.
* A place to store the results, the Dummy app uses a Score model. (Storing)

In the Dummy app, Assessors and Scores are Polymorphic models that tie an Assessing model to an Assessed model. A Take controller distinguishes the
different types of assessments and controls the Taking, Scoring and Storing processes. 

### Assessable Objects

The Published Hash and Post/Score objects are what that Taking and Storing deal with:

The published hash method can be seen in apps/models/assessable/assessment.rb. It uses json methods to create the hash. The Dummy app stores the Published hash
in a serialized column and provides a form of versioning.

    hash = self.as_json(:except => [:created_at, :updated_at ], 
      :include => {:questions => {:except => [:created_at, :updated_at ],
      :include => {:answers => {:except => [:created_at, :updated_at ]}}}})
      
The Parmam[:post] contains an answers array for each questions, and optional text and other_text if required.

  {"answer"=>{"9"=>["43"], "10"=>["50"], "11"=>["57"], "12"=>["64"]}}
  
That hash is then scored and scoring information added. The dummy app allows sections and the post would contain scores for each section.

    {"post"=>{"4"=>{"answer"=>{"9"=>["43"], "10"=>["50"], "11"=>["57"], "12"=>["64"]}, 
    "scores"=>{"max"=>{"raw"=>20.0, "weighted"=>20.0}, "9"=>{"raw"=>2.0, "weighted"=>2.0}, 
    "10"=>{"raw"=>3.0, "weighted"=>3.0}, "11"=>{"raw"=>4.0, "weighted"=>4.0}, 
    "12"=>{"raw"=>5.0, "weighted"=>5.0}, "total"=>{"raw"=>14.0, "weighted"=>14.0}, 
    "percent"=>{"raw"=>0.7, "weighted"=>0.7}}, "all"=>["43", "50", "57", "64"]}}}
    
You take out of the score object what you need and store it. In the Dummy apps case, it again uses a serialized JSON column.

## Author

Written by {Steve Alex}[https://github.com/salex/] - retired Geek.

## Licence

This project uses the MIT-LICENSE.
