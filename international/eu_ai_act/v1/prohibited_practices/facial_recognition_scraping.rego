# RequiredMetrics:
#   - system.builds_facial_recognition_database
#   - system.scrapes_facial_images
#   - system.scraping_is_targeted
#   - system.sources
#
# RequiredParams: none
package international.eu_ai_act.v1.prohibited_practices.facial_recognition_scraping

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act Prohibition of Untargeted Facial Image Scraping",
	"description": "Evaluates an AI system against the Article 5(1)(e) prohibition on creating or expanding facial recognition databases through the untargeted scraping of facial images from the internet or CCTV footage. The operative word is untargeted: the prohibition turns on indiscriminate collection rather than on facial recognition itself, so a database built from images collected for a specific, targeted purpose is assessed differently.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 5(1)(e) of the EU AI Act, untargeted scraping of facial images",
		"Recital 43 of the EU AI Act",
	],
}

# The sources named in Article 5(1)(e).
prohibited_sources := {"internet", "cctv"}

scraped_sources contains src if {
	some src in object.get(input, ["system", "sources"], [])
	src in prohibited_sources
}

default builds_database := false

builds_database if {
	input.system.builds_facial_recognition_database == true
}

default scrapes_untargeted := false

scrapes_untargeted if {
	input.system.scrapes_facial_images == true
	input.system.scraping_is_targeted == false
	count(scraped_sources) > 0
}

default prohibited := false

prohibited if {
	builds_database
	scrapes_untargeted
}

default not_prohibited := false

not_prohibited if {
	not prohibited
}

default assessment_complete := false

assessment_complete if {
	is_boolean(input.system.builds_facial_recognition_database)
	is_boolean(input.system.scrapes_facial_images)
}

default allow := false

allow if {
	assessment_complete
	not prohibited
}

policy_metrics := {
	"builds_facial_recognition_database": {
		"name": "Creates or Expands a Facial Recognition Database",
		"value": builds_database,
		"control_passed": not_prohibited,
	},
	"untargeted_scraping": {
		"name": "Untargeted Scraping of Facial Images",
		"value": scrapes_untargeted,
		"control_passed": not_prohibited,
	},
	"prohibited_sources_used": {
		"name": "Article 5(1)(e) Sources Used",
		"value": sort([s | some s in scraped_sources]),
		"control_passed": not_prohibited,
	},
	"assessment_complete": {
		"name": "Article 5(1)(e) Assessment Recorded",
		"value": assessment_complete,
		"control_passed": assessment_complete,
	},
}

report := reporting.compose_report("eu_ai_act.prohibited_practices.facial_recognition_scraping", allow, policy_metrics)
