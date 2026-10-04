# shellcheck shell=bash
# Functions that the tests in this folder share. A test file sources this file, checks its cases
# with expect_block and expect_allow, and ends with finish_tests. scripts/check runs every test file.

hooks_folder=$(cd "${BASH_SOURCE[0]%/*}" && pwd)
test_name=${0#./}
case_count=0
failed_cases=0

# The hook runs with this home folder, so that the cases don't depend on the machine.
# It's outside /home, because macOS looks up each path in /home over the network.
test_home=/home-for-tests/someone

# Prints a sample of what a tool sends the hook before an action: sample_input <tool> <Bash or Read> <command or path>
# Every tool uses Claude Code's field names. Cursor calls its shell tool Shell, and Codex has no Read.
sample_input() {
  local tool=$1 tool_name=$2 value=$3 tool_input
  if [[ $tool_name == Bash ]]; then
    tool_input=$(jq -n --arg command "$value" '{command: $command}')
  else
    tool_input=$(jq -n --arg path "$value" '{file_path: $path}')
  fi
  case $tool in
    claude-code)
      jq -n --arg home "$test_home" --arg tool_name "$tool_name" --argjson tool_input "$tool_input" \
        '{session_id: "abc123", transcript_path: "\($home)/.claude/projects/p/abc123.jsonl",
          cwd: "\($home)/project", permission_mode: "default", hook_event_name: "PreToolUse",
          tool_name: $tool_name, tool_input: $tool_input, tool_use_id: "toolu_01"}'
      ;;
    codex)
      jq -n --arg home "$test_home" --argjson tool_input "$tool_input" \
        '{session_id: "abc123", turn_id: "1", transcript_path: null, cwd: "\($home)/project",
          hook_event_name: "PreToolUse", model: "gpt-5", permission_mode: "default",
          tool_name: "Bash", tool_input: $tool_input, tool_use_id: "call_01"}'
      ;;
    copilot-cli)
      jq -n --arg home "$test_home" --arg tool_name "$tool_name" --argjson tool_input "$tool_input" \
        '{session_id: "abc123", timestamp: 1759536000000, cwd: "\($home)/project",
          hook_event_name: "PreToolUse", tool_name: $tool_name, tool_input: $tool_input}'
      ;;
    cursor)
      if [[ $tool_name == Bash ]]; then
        tool_name=Shell
      fi
      jq -n --arg home "$test_home" --arg tool_name "$tool_name" --argjson tool_input "$tool_input" \
        '{conversation_id: "abc123", generation_id: "def456", model: "auto", hook_event_name: "PreToolUse",
          cursor_version: "2.1.0", workspace_roots: ["\($home)/project"], transcript_path: null,
          tool_name: $tool_name, tool_input: $tool_input}'
      ;;
  esac
}

# Prints the tools that send an action: tools_for <Bash or Read>
tools_for() {
  if [[ $1 == Bash ]]; then
    echo claude-code codex copilot-cli cursor
  else
    echo claude-code copilot-cli cursor
  fi
}

# Runs the hook on an input, and sets hook_status and hook_message: run_hook <input>
run_hook() {
  hook_status=0
  hook_message=$(HOME=$test_home "$hooks_folder/before-tool" 2>&1 >/dev/null <<<"$1") || hook_status=$?
}

# Checks the hook's result for one case: expect_result <description> <exit code> <message>
expect_result() {
  local description=$1 status=$2 message=$3
  case_count=$((case_count + 1))
  if [[ $hook_status != "$status" || $hook_message != "$message" ]]; then
    echo "error: $description must exit with code $status and the message \"$message\", but it exited with code $hook_status and the message \"$hook_message\"." >&2
    failed_cases=$((failed_cases + 1))
  fi
}

# Checks that the hook blocks an action in every tool that sends it: expect_block <Bash or Read> <command or path> <message>
expect_block() {
  local tool
  for tool in $(tools_for "$1"); do
    run_hook "$(sample_input "$tool" "$1" "$2")"
    expect_result "In $tool, the hook for $1 \"$2\"" 2 "$3"
  done
}

# Checks that the hook allows an action in every tool that sends it: expect_allow <Bash or Read> <command or path>
expect_allow() {
  local tool
  for tool in $(tools_for "$1"); do
    run_hook "$(sample_input "$tool" "$1" "$2")"
    expect_result "In $tool, the hook for $1 \"$2\"" 0 ""
  done
}

finish_tests() {
  if ((failed_cases > 0)); then
    echo "error: $failed_cases of the $case_count cases in $test_name failed. The errors above say which." >&2
    exit 1
  fi
  echo "$test_name passed. Cases: $case_count."
}
