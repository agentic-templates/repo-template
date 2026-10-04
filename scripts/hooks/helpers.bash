# shellcheck shell=bash
# Functions that the checks in this folder share. A check sources this file first.

# A check blocks only with exit code 2. Any other failure, such as a jq error, ends the check
# with code 1, which allows the action, because a broken hook must never stop work.
# Some commands fail with code 2 themselves, so the trap replaces their code.
set -eEuo pipefail
trap 'exit 1' ERR

# Reads the tool's input from stdin into these variables. Every tool sends Claude Code's form:
# one JSON object, with the tool in tool_name and its input in tool_input.
# - tool_name: the tool, such as Bash or Read. Cursor's Shell counts as Bash.
# - shell_command: the command that Bash runs, or empty.
# - patch: the patch text that Codex's apply_patch applies, or empty.
# - file_path: the file that Read, Write or Edit uses, or empty.
# - cwd: the folder the agent works in, or empty if the tool doesn't send it.
read_input() {
  local input
  input=$(jq -c .)
  tool_name=$(jq -r '.tool_name // "" | tostring' <<<"$input")
  if [[ $tool_name == Shell ]]; then
    tool_name=Bash
  fi
  shell_command=""
  patch=""
  if [[ $tool_name == apply_patch ]]; then
    patch=$(jq -r '.tool_input.command // "" | tostring' <<<"$input")
  else
    shell_command=$(jq -r '.tool_input.command // "" | tostring' <<<"$input")
  fi
  file_path=$(jq -r '.tool_input.file_path // "" | tostring' <<<"$input")
  cwd=$(jq -r '.cwd // "" | tostring' <<<"$input")
}

# Blocks the action, and tells the agent why: block <reason>
block() {
  printf '%s\n' "$1" >&2
  exit 2
}

# Sets the array command_words to a simple command's words from the command's name on, without the sudo,
# env and NAME=value words before it: drop_command_prefixes <word>...
drop_command_prefixes() {
  command_words=("$@")
  while ((${#command_words[@]} > 0)); do
    if [[ ${command_words[0]} != sudo && ${command_words[0]} != env && ! ${command_words[0]} =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then
      return 0
    fi
    command_words=("${command_words[@]:1}")
  done
}

# Splits a shell command into simple commands, and calls a function with the words of each one:
# for_each_simple_command <function> <command>
# Simple commands end at &&, ||, ;, |, &, a parenthesis and a line break. Words end at spaces and tabs.
# Quotes and backslashes are removed as the shell removes them, but nothing is expanded, so "$HOME" stays $HOME.
# Redirections, such as "< .env" or "2>/dev/null", aren't words. Before each call, the array redirections
# holds them as pairs: the operator, such as < or 2>, then its target.
# It doesn't handle every shell feature, such as $( ) inside quotes, backticks or here-documents.
for_each_simple_command() {
  local function=$1 text=$2
  local length=${#text} i char next
  local word="" has_word=false quote="" descriptor="" operator="" starts_redirection
  local -a words=()
  redirections=()

  for ((i = 0; i <= length; i++)); do
    char=${text:i:1}
    next=${text:i+1:1}

    if [[ -n $quote && i -lt length ]]; then
      if [[ $char == "$quote" ]]; then
        quote=""
      elif [[ $quote == '"' && $char == "\\" && $next == [\"\\\$\`] ]]; then
        word+=$next
        i=$((i + 1))
      else
        word+=$char
      fi
      continue
    fi

    if ((i < length)); then
      case $char in
        "'" | '"')
          quote=$char
          has_word=true
          continue
          ;;
        \\)
          # A backslash at the end of a line joins the line to the next one.
          if [[ $next != $'\n' ]]; then
            word+=$next
            has_word=true
          fi
          i=$((i + 1))
          continue
          ;;
        '#')
          if ! $has_word; then
            # A comment runs to the end of the line.
            while [[ -n ${text:i+1:1} && ${text:i+1:1} != $'\n' ]]; do
              i=$((i + 1))
            done
            continue
          fi
          ;;
      esac
      if [[ $char != [[:space:]\;\&\|\(\)\<\>] ]]; then
        word+=$char
        has_word=true
        continue
      fi
    fi

    # The character ends the current word.
    starts_redirection=false
    if [[ $char == [\<\>] || ($char == '&' && $next == '>') ]]; then
      starts_redirection=true
    fi
    if $has_word; then
      if [[ -n $operator ]]; then
        redirections+=("$operator" "$word")
        operator=""
      elif $starts_redirection && [[ $word =~ ^[0-9]+$ ]]; then
        descriptor=$word
      else
        words+=("$word")
      fi
      word="" has_word=false
    fi

    if $starts_redirection; then
      operator=$descriptor$char
      descriptor=""
      while [[ ${text:i+1:1} == [\<\>] ]]; do
        i=$((i + 1))
        operator+=${text:i:1}
      done
      if [[ ${text:i+1:1} == [\&\|-] ]]; then
        i=$((i + 1))
        operator+=${text:i:1}
      fi
    elif ((i == length)) || [[ $char != [[:blank:]] ]]; then
      # A line break, ;, &, |, a parenthesis or the end of the command ends the simple command.
      if ((${#words[@]} > 0)); then
        "$function" "${words[@]}"
      fi
      words=()
      redirections=()
      operator=""
    fi
  done
}
