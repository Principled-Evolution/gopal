package international.eu_ai_act.v1.prohibited_practices.facial_recognition_scraping_test

import data.international.eu_ai_act.v1.prohibited_practices.facial_recognition_scraping as policy
import rego.v1

scraping := {"system": {
	"builds_facial_recognition_database": true,
	"scrapes_facial_images": true,
	"scraping_is_targeted": false,
	"sources": ["internet"],
}}

test_deny_untargeted_internet_scraping if {
	not policy.allow with input as scraping
}

test_deny_untargeted_cctv_scraping if {
	not policy.allow with input as json.patch(scraping, [{"op": "replace", "path": "/system/sources", "value": ["cctv"]}])
}

# The operative word is untargeted. Targeted collection for a specific purpose
# is assessed differently by Article 5(1)(e).
test_allow_targeted_collection if {
	policy.allow with input as json.patch(scraping, [{"op": "replace", "path": "/system/scraping_is_targeted", "value": true}])
}

# The prohibition is about building the database, not about facial recognition
# as such.
test_allow_when_not_building_a_database if {
	policy.allow with input as json.patch(scraping, [{"op": "replace", "path": "/system/builds_facial_recognition_database", "value": false}])
}

# Sources outside the Article's list do not engage it.
test_allow_when_source_not_internet_or_cctv if {
	policy.allow with input as json.patch(scraping, [{"op": "replace", "path": "/system/sources", "value": ["licensed_stock_library"]}])
}

test_report_names_the_prohibited_sources if {
	report := policy.report with input as json.patch(scraping, [{"op": "replace", "path": "/system/sources", "value": ["cctv", "internet", "partner_feed"]}])
	report.metrics.prohibited_sources_used.value == ["cctv", "internet"]
}

test_deny_when_assessment_not_recorded if {
	not policy.allow with input as {"system": {"sources": ["internet"]}}
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
