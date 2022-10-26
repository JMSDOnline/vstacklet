#!/usr/bin/awk -f
################################################################################
# <START METADATA>
# @file_name: doc.awk
# @version: 1.0.31
# @description: automated documentation
# @project_name: vstacklet
#
# @save_tasks:
#  automated_versioning: true
#  automated_documentation: false
#
# @author: Jason Matthews (JMSolo)
# @author_contact: https://github.com/JMSDOnline/vstacklet
#
# @license: MIT License (Included in LICENSE)
# Copyright (C) 2016-2022, Jason Matthews
# All rights reserved.
# <END METADATA>
################################################################################

BEGIN {
    styles["empty", "from"] = ".*"
    styles["empty", "to"] = ""
    styles["h1", "from"] = ".*"
    styles["h1", "to"] = "# &"
    styles["h2", "from"] = ".*"
    styles["h2", "to"] = "## &"
    styles["h3", "from"] = ".*"
    styles["h3", "to"] = "### &"
    styles["h4", "from"] = ".*"
    styles["h4", "to"] = "#### &"
    styles["h5", "from"] = ".*"
    styles["h5", "to"] = "##### &"
    styles["code", "from"] = ".*"
    styles["code", "to"] = "```&"
    styles["/code", "to"] = "```"
    styles["argN", "from"] = "^(\\$[0-9]) (\\S+)"
    styles["argN", "to"] = "**\\1** (\\2):"
    styles["arg@", "from"] = "^\\$@ (\\S+)"
    styles["arg@", "to"] = "**...** (\\1):"
	styles["paramN", "from"] = "^(\\$[0-9]) (\\S+)"
    styles["paramN", "to"] = "**\\1** (\\2):"
    styles["param@", "from"] = "^\\$@ (\\S+)"
    styles["param@", "to"] = "**...** (\\1):"
    styles["li", "from"] = ".*"
    styles["li", "to"] = "- &"
    styles["i", "from"] = ".*"
    styles["i", "to"] = "*&*"
    styles["anchor", "from"] = ".*"
    styles["anchor", "to"] = "[&](#&)"
    styles["exitcode", "from"] = "([>!]?[0-9]{1,3}) (.*)"
    styles["exitcode", "to"] = "**\\1**: \\2"
    output_format["readme", "h1"] = "h1"
    output_format["readme", "h2"] = "h2"
    output_format["readme", "h3"] = "h3"
    output_format["readme", "h4"] = "h4"
    output_format["readme", "h5"] = "h5"
}

function render(type, text) {
    if((style,type) in output_format){
        type = output_format[style,type]
    }
    return gensub( \
        styles[type, "from"],
        styles[type, "to"],
        "g",
        text \
    )
}

function reset() {
    has_example = 0
    has_args = 0
	has_params = 0
    has_exitcode = 0
    has_stdout = 0

    content_desc = ""
    content_example  = ""
    content_args = ""
	content_params = ""
    content_exitcode = ""
    content_seealso = ""
    content_stdout = ""
}

/^[[:space:]]*# @internal/ {
    is_internal = 1
}

/^[[:space:]]*# @file_name/ {
    sub(/^[[:space:]]*# @file_name: /, "")
    filedoc = render("h1", $0) " - "
}

/^[[:space:]]*# @version/ {
    sub(/^[[:space:]]*# @version: /, "")
    filedoc = filedoc "v"$0 "\n"
}



/^[[:space:]]*# @brief:/ {
    sub(/^[[:space:]]*# @brief: /, "")
    filedoc = filedoc $0 "\n"
}


/^[[:space:]]*# @description:/ {
    in_description = 1
    in_example = 0

    reset()

    docblock = ""
}

in_description {
    if (/^[^[[:space:]]*#]|^[[:space:]]*# @[^d]|^[[:space:]]*[^#]/) {
        if (!match(content_desc, /\n$/)) {
            content_desc = content_desc "\n"
        }
        in_description = 0
    } else {
        sub(/^[[:space:]]*# @description: /, "")
        sub(/^[[:space:]]*# /, "")
        sub(/^[[:space:]]*#$/, "")

        content_desc = content_desc "\n" $0
    }
}

in_example {
    #if (! /^[[:space:]]*# [ ]{3}/) {
	if (/^[^[[:space:]]*#]|^[[:space:]]*# @[^example]|^[[:space:]]*[^#]/) {
		if (!match(content_example, /\n$/)) {
            content_example = content_example "\n" render("/code") "\n"
        }
        in_example = 0

        #content_example = content_example "\n" render("/code") "\n"
    } else {
        sub(/^[[:space:]]*#[ ]{3}/, "")
		sub(/^[[:space:]]*# /, "")
        #sub(/^[[:space:]]*#$/, "")

        content_example = content_example "\n" $0
    }
}

/^[[:space:]]*# @example/ {
    in_example = 1
    content_example = content_example "\n" render("h4", "examples:") "\n"
	sub(/^[[:space:]]*# @example:/, "")
    content_example = content_example "\n" render("code", "\n"$0, "bash")
}

/^[[:space:]]*# @arg/ {
    if (!has_args) {
        has_args = 1

        content_args = content_args "\n" render("h4", "arguments:") "\n\n"
    }

    sub(/^[[:space:]]*# @arg:/, "")
    $0 = render("argN", $0)
    $0 = render("arg@", $0)
    content_args = content_args render("li", $0) "\n"
}

/^[[:space:]]*# @noargs/ {
    content_args = content_args "\n" render("i", "function has no arguments") "\n"
}

/^[[:space:]]*# @param/ {
	if (!has_params) {
		has_params = 1

		content_params = content_params "\n" render("h4", "parameters:") "\n\n"
	}

	sub(/^[[:space:]]*# @param:/, "")
	$0 = render("paramN", $0)
	$0 = render("param@", $0)
	content_params = content_params render("li", $0) "\n"
}

/^[[:space:]]*# @noparams/ {
    content_params = content_params "\n" render("i", "function has no parameters") "\n"
}

/^[[:space:]]*# @return_code/ {
    if (!has_exitcode) {
        has_exitcode = 1

        content_exitcode = content_exitcode "\n" render("h4", "return codes:") "\n\n"
    }

    sub(/^[[:space:]]*# @return_code: /, "")

    $0 = render("returncode", $0)

    content_exitcode = content_exitcode render("li", $0) "\n"
}

/^[[:space:]]*# @stdout/ {
    has_stdout = 1
    sub(/^[[:space:]]*# @stdout /, "")
    content_stdout = content_stdout "\n" render("h4", "stdout")
    content_stdout = content_stdout "\n\n" render("li", $0) "\n"
}

{
    docblock = content_desc content_args content_params content_exitcode content_stdout content_example content_seealso
}

/^[ \t]*(function([ \t])+)?([a-zA-Z0-9_:-]+)([ \t]*)(\(([ \t]*)\))?[ \t]*\{/ && docblock != "" && !in_example {
    if (is_internal) {
        is_internal = 0
    } else {
        func_name = gensub(\
            /^[ \t]*(function([ \t])+)?([a-zA-Z0-9_:-]+)[ \t]*\(.*/, \
            "\\3()", \
            "g" \
        )
        doc = doc "\n" render("h3", func_name) "\n" docblock
    }

    docblock = ""
    reset()
}

END {
    if (filedoc != "") {
        print filedoc 
    }
    print doc "\n"
}