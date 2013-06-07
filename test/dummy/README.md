The roots of Assessable were developed at an agency where an on-line job application process was needed. This process was provided as a service of the agency customers
and not for jobs with the agency.  The purpose was to screen potential applicants by
asking a series of question. The questions were designed to evaluate areas such as work history, work skills, attitude, background, etc. These areas were
scored both separately and as an aggregate score.
Applicants scores and text areas of the applications were evaluated and the top applicants were then progressed to the next stage in the selection process (e.g., interview, a battery of tests/evaluations).

This is not your simple 1 to 5 survey. If your application is a simple survey, Assessable is probably overkill. There are numerous examples of implementing a simple
survey/questions/answers model out there (screencasts, gems).

The on-line application presented several problems.

* The assessments were tailored for a specific job, but there were some questions (general) that were asked for each job.
* The assessments were often developed at the last minute and often contained errors that were not discovered immediately.
  * For example, misspelling, question not clear, answer value/weight not getting intended results.
* Scoring general questions may be different for each job.
* Some answers required asking another question (Are you a US Citizen? - no response requests work permit number)

There were often hundreds, if not thousands o applications for jobs. An error or an omission required management decisions and what changes were needed and what the effects would be of those already scored. 

It was also discovered that there were other processes at the agency that a {evaluation/survey/quiz}/questions/answers model was useful. Code was duplicated and of course maintainability became a problem. Assessable was developed to take at least some of functions of this process and put them in one place. That solves some
problems, but the different behaviors must be implemented in the host application.

Realistically, Assessable is pretty simplistic - it just manages CRUD models, generates and displays assessments and scores the answers.

For a simple host application, it just needs a link to an assessment to administer and score the assessment. Then do something with the results.

The Dummy Application inside the engine demonstrate usage of the engine in a simulated environment. The basic model is

* Assessing model(s) (different model behaviors simulated in the Stage model)
* Assessors - belongs to Assessing (polymorphic), has many AssessorSections, has many Scores through AssessorSections
* AssessorSection - belongs to Assessor, has many Scores - links to AssessableAssessment
* Assessed - has many scores (different user roles simulated in the User model)
* Scores - belongs to Assessed (polymorphic), belongs to AssessorSection.

The polymorphic approach is not needed, but allows Scores and Assessors be on one place, but separated by the polymorphic type. If you only have
one assessed model and one assessing model, you just replace the polymorphic relations.

While the above structure manages most of the needs of the original application, there was still a need for an assessment that was the same for all instances of an assessed model. 
An example would be an annual evaluation for a certain class of person (e.g., instructor). In the Dummy application a model_assessor table was added to define
these types of assessors. That table then has many assessors the assessed model looks for assessors through model_assessors.  The Instructor model in the Dummy application demonstrates this approach using a repeating assessment/evaluation.

The AssessorSection model stores the entire published AssessableAssessment object. This so the creation of the object in not needed each time someone is assessed.
This also allows versioning of the assessment to take care problems
described above where changes are needed. If changes are made to the assessment, you can either:

* replace the published version with the new version, and re-score all the scores if necessary
* archive the section and clone the new version to a new section and manage the difference through evaluation.

The Dummy Application has links on the home page and in the Users list that demonstrates using Assessable to administer:

* An on-line type application process
* An anonymous type survey
  * only one score is stored that accumulates the answers.
* Score an quiz or evaluation
* Evaluate a process or person.

A [Take class](https://github.com/salex/Assessable/blob/master/test/dummy/app/models/take.rb) 
and [Take controller](https://github.com/salex/Assessable/blob/master/test/dummy/app/controllers/take_controller.rb) interfaces with 
Assessable through an [Assessing class](https://github.com/salex/Assessable/blob/master/app/models/assessable/assessing.rb) 
that has several class and instance helper methods that interface with Assessable without namespacing. Assessable has a model Stash that is basically a session store to allows managing multi-step (wizard) forms. A data and session field allows you to control the steps.

The test users have roles and control if they can apply, score, or evaluate. There are also hooks that allow for before and after model instance methods. Again,
this has nothing to do with Assessable, but your application needs. For instance a user with a Citizen role may have information stored in their 
Citizen record that an
instance method could be called that would build a post object based on that information and then call score_assessment to score that information (e.g. current education). An after hook could be called to rollup all the section scores and update the assessed record.














