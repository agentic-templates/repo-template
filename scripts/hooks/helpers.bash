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

# The flags of gh api that take a value, as gh api --help lists them.
api_flags_with_value=" --cache -F --field -H --header --hostname --input -q --jq -X --method -p --preview -f --raw-field -t --template "

# The flags that take a value, as gh issue create --help, gh issue edit --help and gh pr close --help list them.
issue_create_flags_with_value=" -a --assignee --attach --blocked-by --blocking -b --body -F --body-file -l --label -m --milestone --parent -p --project --recover -T --template -t --title --type -R --repo "
issue_edit_flags_with_value=" --add-assignee --add-blocked-by --add-blocking --add-label --add-project --add-sub-issue --attach -b --body -F --body-file -m --milestone --parent --remove-assignee --remove-blocked-by --remove-blocking --remove-label --remove-project --remove-sub-issue -t --title --type -R --repo "
pr_close_flags_with_value=" -c --comment -R --repo "

# Reads the words of a gh command from an index on, and sets these variables:
# - argument: the first word that isn't a flag or a flag's value, or empty
# - target: the words that name the argument to other gh commands: the argument, and -R or --repo with its value
# - flags: the flags, without their values
# - flag_values: the value of each flag in flags that takes the next word as its value, or empty
# read_arguments <index> <flags that take a value>
read_arguments() {
  local i word
  local -a repository=()
  argument="" target=() flags=() flag_values=()
  for ((i = $1; i < ${#command_words[@]}; i++)); do
    word=${command_words[i]}
    case $word in
      -R | --repo)
        repository=(--repo "${command_words[i + 1]:-}")
        i=$((i + 1))
        ;;
      --repo=*) repository=(--repo "${word#--repo=}") ;;
      -*)
        flags+=("$word")
        if [[ $word != *=* && $2 == *" $word "* ]]; then
          flag_values+=("${command_words[i + 1]:-}")
          i=$((i + 1))
        else
          flag_values+=("")
        fi
        ;;
      *)
        if [[ -z $argument ]]; then
          argument=$word
          target=("$word")
        fi
        ;;
    esac
  done
  target+=(${repository[@]+"${repository[@]}"})
}

# Succeeds if read_arguments found one of these flags: has_flag <flag>...
has_flag() {
  local flag wanted
  for flag in ${flags[@]+"${flags[@]}"}; do
    for wanted in "$@"; do
      if [[ $flag == "$wanted" ]]; then
        return 0
      fi
    done
  done
  return 1
}

# The flags of gh pr create that take a value, as gh pr create --help lists them.
pr_create_flags_with_value=" -a --assignee --attach -B --base -b --body -F --body-file -H --head -l --label -m --milestone -p --project --recover -r --reviewer -T --template -t --title -R --repo "

# Succeeds if command_words opens a pull request with gh pr create, or its alias gh pr new, rather than show the
# command's help or do a dry run. It sets pr_base, pr_head and pr_title to the values of --base, --head and --title,
# or to empty when the command doesn't give the flag, and pr_has_title to yes when it gives --title, whose value can
# be empty. It sets body_source, body_word and body_file for read_body, and empties body_may_expand.
# The word after a flag that takes a value is that value, even if it starts with a dash.
opens_pull_request() {
  local i word flag value
  if [[ ${command_words[0]##*/} != gh || ${command_words[1]:-} != pr ]]; then
    return 1
  fi
  if [[ ${command_words[2]:-} != create && ${command_words[2]:-} != new ]]; then
    return 1
  fi
  pr_base="" pr_head="" pr_title="" pr_has_title="" body_source="" body_word="" body_file="" body_may_expand=""
  for ((i = 3; i < ${#command_words[@]}; i++)); do
    word=${command_words[i]}
    case $word in
      -h | --help | --dry-run) return 1 ;;
      --*=*)
        flag=${word%%=*}
        value=${word#*=}
        ;;
      -*)
        flag=$word
        value=""
        if [[ $pr_create_flags_with_value == *" $word "* ]]; then
          value=${command_words[i + 1]:-}
          i=$((i + 1))
        fi
        ;;
      *) continue ;;
    esac
    case $flag in
      -B | --base) pr_base=$value ;;
      -H | --head) pr_head=$value ;;
      -t | --title) pr_title=$value pr_has_title=yes ;;
      -b | --body) body_source=text body_word=$value ;;
      -F | --body-file) body_source=file body_file=$value ;;
    esac
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

# A here-document's delimiter, after << or <<-, and with or without quotes. Group 1 holds the - and group 3 the word.
quote_characters=\'\"
heredoc_operator="<<(-?)[[:blank:]]*([$quote_characters\\\\]?)([A-Za-z_][A-Za-z0-9_]*)[$quote_characters]?"
# split_heredocs puts this character around a here-document's number. Commands don't contain it.
marker=$'\037'
heredoc_reference="$marker([0-9]+)$marker"

# Takes the bodies of the here-documents out of a command, because a body holds text and not commands, and a quote in
# the text would end the word that holds it, such as the --body word in --body "$(cat <<'EOF' ... EOF)":
# split_heredocs <command>
# Sets command_text to the command without the bodies, with the marker, a number and the marker in place of each
# delimiter, and heredocs to the bodies, in order. It takes each << as the start of a here-document, also in quoted
# text outside $( ), where the shell doesn't.
split_heredocs() {
  local line rest match prefix body body_line index=0 count j
  local -a lines=() dashes=() delimiters=()
  command_text=""
  heredocs=()
  while IFS= read -r line; do
    lines+=("$line")
  done <<<"$1"
  count=${#lines[@]}
  while ((index < count)); do
    rest=${lines[index]}
    index=$((index + 1))
    line=""
    dashes=()
    delimiters=()
    while [[ $rest =~ $heredoc_operator ]]; do
      match=${BASH_REMATCH[0]}
      prefix=${rest%%"$match"*}
      rest=${rest#*"$match"}
      # <<< starts a string, not a here-document.
      if [[ $prefix == *"<" ]]; then
        line+=$prefix$match
        continue
      fi
      line+="$prefix<<${BASH_REMATCH[1]}$marker$((${#heredocs[@]} + ${#delimiters[@]}))$marker"
      dashes+=("${BASH_REMATCH[1]}")
      delimiters+=("${BASH_REMATCH[3]}")
    done
    command_text+=$line$rest$'\n'
    # The bodies follow the line, in the order of their operators. <<- removes the tabs at the start of each line.
    for ((j = 0; j < ${#delimiters[@]}; j++)); do
      body=""
      while ((index < count)); do
        body_line=${lines[index]}
        index=$((index + 1))
        if [[ -n ${dashes[j]} ]]; then
          body_line=${body_line#"${body_line%%[!$'\t']*}"}
        fi
        if [[ $body_line == "${delimiters[j]}" ]]; then
          break
        fi
        body+=$body_line$'\n'
      done
      heredocs+=("$body")
    done
  done
}

# Adds the files that the redirections of a simple command write to the array written_files, which a check empties
# before the first simple command of each command. The hook can't read such a file before the command runs.
record_written_files() {
  local i
  # >& joins two outputs.
  for ((i = 0; i < ${#redirections[@]}; i += 2)); do
    if [[ ${redirections[i]} == *">"* && ${redirections[i]} != *"&" ]]; then
      written_files+=("${redirections[i + 1]}")
    fi
  done
}

# Succeeds if an earlier part of the command writes a file, as a redirection names it: is_written <path>
is_written() {
  local file
  for file in ${written_files[@]+"${written_files[@]}"}; do
    if [[ $file == "$1" ]]; then
      return 0
    fi
  done
  return 1
}

# Sets body to the text of a file, or blocks when the hook can't read the file before the command runs:
# read_body_file <path as the command writes it>
read_body_file() {
  local path=$1
  # The command's words come as written, so ~ is matched before the shell expands it.
  # shellcheck disable=SC2088
  case $path in
    "~/"*) path=$HOME/${path#"~/"} ;;
  esac
  if is_written "$1" || [[ ! -f $path || ! -r $path ]]; then
    block "Blocked: this hook checks the body file before the command runs, and $1 doesn't exist yet or the command writes it. Write the file in a command of its own first, and give its path without variables."
  fi
  body=$(<"$path")
}

give_the_body="Give the body with --body, or write it to a file and give the file with --body-file."

# Sets body to the body that a gh command gives, and body_may_expand to yes if the shell would change it, or blocks
# when the hook can't read the body: read_body <what the hook checks, such as: the issue's headings>
# It reads the body as the command writes it, without running $( ) or filling in variables: from --body, from the
# file that --body-file names, or from a here-document. It reads what the check found in the command's words:
# body_source (empty, text or file), body_word and body_file. Run split_heredocs on the command first.
read_body() {
  local rest i
  body=""
  case $body_source in
    "")
      block "Blocked: the command gives no body, so this hook can't check $1. $give_the_body"
      ;;
    text)
      if [[ ! $body_word =~ $heredoc_reference ]]; then
        body=$body_word
        if [[ $body == *[\$\`]* ]]; then
          body_may_expand=yes
        fi
        return 0
      fi
      # The text of each here-document in the word, such as "$(cat <<'EOF' ... EOF)"
      rest=$body_word
      while [[ $rest =~ $heredoc_reference ]]; do
        body+=${heredocs[BASH_REMATCH[1]]}
        rest=${rest#*"${BASH_REMATCH[0]}"}
      done
      ;;
    file)
      if [[ $body_file != - ]]; then
        read_body_file "$body_file"
        return 0
      fi
      # Standard input, from a here-document or a file
      for ((i = 0; i < ${#redirections[@]}; i += 2)); do
        if [[ ${redirections[i]} =~ ^0?\<\<-?$ && ${redirections[i + 1]} =~ $heredoc_reference ]]; then
          body=${heredocs[BASH_REMATCH[1]]}
          return 0
        fi
        if [[ ${redirections[i]} =~ ^0?\<$ ]]; then
          read_body_file "${redirections[i + 1]}"
          return 0
        fi
      done
      block "Blocked: this hook can't read a body from standard input, other than from a here-document, so it can't check $1. $give_the_body"
      ;;
  esac
}
