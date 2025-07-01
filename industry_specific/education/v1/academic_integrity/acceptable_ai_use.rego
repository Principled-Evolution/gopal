package industry_specific.education.v1.academic_integrity

# @title Detailed Acceptable AI Use
# @description This policy defines the acceptable use of AI tools by students based on the course policy and the type of assignment.
# @version 1.1

# Default to not allowed unless explicitly permitted by the course policy.
default allow := false

# --- Allow Rules ---

# Allow if the specific AI use case is permitted in the course's AI policy.
allow if {
	is_permitted_use(input.ai_use_case, input.course.ai_policy, permitted_uses)
}

# Allow if the student is using a generally accepted tool for a common task (e.g., spell check).
allow if {
	is_common_assistive_tool(input.ai_tool)
}

# --- Deny Messages ---

deny contains msg if {
	not allow
	msg := sprintf("The use of AI tool '%v' for '%v' is not permitted for this assignment according to the course policy.", [input.ai_tool, input.ai_use_case])
}

# --- Helper Functions ---

# Defines permitted uses based on different policy levels (e.g., "strict", "moderate", "open").
permitted_uses := {
	"strict": {"spell_check", "grammar_check"},
	"moderate": {"spell_check", "grammar_check", "research_assistance", "code_completion"},
	"open": {"spell_check", "grammar_check", "research_assistance", "code_completion", "content_generation_with_attribution"},
}

# Checks if a use case is permitted under the given policy level.
is_permitted_use(use_case, policy, uses) if {
	use_case in uses[policy.level]
}

# Checks if the tool is a common, generally accepted assistive tool.
is_common_assistive_tool(tool) if {
	common_tools := {"grammarly", "spell_check_pro"}
	tool in common_tools
}
