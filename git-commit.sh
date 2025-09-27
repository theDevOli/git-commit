#!/bin/bash
#
# git-commit.sh - Standardize Git commit messages with emojis, types, and optional scopes.
# Usage: git-commit <type-number> [scope] <description>
#

set -e

# Colors for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variable for corrected message
CORRECTED_COMMIT_MSG=""

# Commit types with descriptions (no emojis)
declare -A TYPES=(
    [1]="feat:New feature"
    [2]="fix:Bug fix"
    [3]="refactor:Code restructuring without behavior change"
    [4]="perf:Performance improvement"
    [5]="test:Adding or updating tests"
    [6]="chore:Build process, tooling, dependencies"
    [7]="docs:Documentation changes"
    [8]="style:Formatting (no code change)"
)

# Emojis mapping
declare -A EMOJIS=(
    [1]="✨"
    [2]="🐛"
    [3]="♻️"
    [4]="⚡"
    [5]="🧪"
    [6]="🔧"
    [7]="📚"
    [8]="💄"
)

# Common technical terms that shouldn't be flagged as spelling errors
declare -A TECHNICAL_TERMS=(
    ["git"]=1
    ["auth"]=1
    ["api"]=1
    ["db"]=1
    ["sql"]=1
    ["html"]=1
    ["css"]=1
    ["js"]=1
    ["json"]=1
    ["xml"]=1
    ["url"]=1
    ["uri"]=1
    ["http"]=1
    ["https"]=1
    ["ssl"]=1
    ["tls"]=1
    ["ui"]=1
    ["ux"]=1
    ["cli"]=1
    ["ci"]=1
    ["cd"]=1
    ["aws"]=1
    ["azure"]=1
    ["gcp"]=1
    ["kubernetes"]=1
    ["docker"]=1
    ["k8s"]=1
    ["redis"]=1
    ["mongodb"]=1
    ["postgresql"]=1
    ["mysql"]=1
    ["node"]=1
    ["python"]=1
    ["java"]=1
    ["ruby"]=1
    ["php"]=1
    ["go"]=1
    ["rust"]=1
    ["commit"]=1
    ["repo"]=1
    ["branch"]=1
    ["merge"]=1
    ["pr"]=1
    ["pullrequest"]=1
    ["config"]=1
    ["env"]=1
    ["var"]=1
    ["param"]=1
    ["arg"]=1
    ["func"]=1
    ["method"]=1
    ["class"]=1
    ["obj"]=1
    ["attr"]=1
    ["prop"]=1
    ["dbconn"]=1
    ["dbconnstr"]=1
    ["oauth"]=1
    ["jwt"]=1
    ["jsonwebtoken"]=1
    ["linter"]=1
    ["eslint"]=1
    ["prettier"]=1
    ["webpack"]=1
    ["babel"]=1
    ["typescript"]=1
    ["tsconfig"]=1
    ["eslintconfig"]=1
)

# Function to print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

# Function to correct the commit message
correct_commit_message() {
    local original_message="$1"
    shift
    local misspelled_words=("$@")
    
    local corrected_message="$original_message"
    local changes_made=false
    
    for word in "${misspelled_words[@]}"; do
        echo
        print_color $YELLOW "Correcting: '$word'"
        
        # Get suggestions if available
        local suggestions=""
        if command -v aspell >/dev/null 2>&1; then
            suggestions=$(echo "$word" | aspell -a 2>/dev/null | \
                         grep -E '^&' | head -1 | cut -d: -f2 | tr ',' '\n' | \
                         head -5 | tr -d ' ' | tr '\n' ' ' | sed 's/ $//')
        elif command -v hunspell >/dev/null 2>&1; then
            suggestions=$(echo "$word" | hunspell -a 2>/dev/null | \
                         grep -E '^&' | head -1 | cut -d: -f2 | tr ',' '\n' | \
                         head -5 | tr -d ' ' | tr '\n' ' ' | sed 's/ $//')
        fi
        
        if [[ -n "$suggestions" ]]; then
            print_color $BLUE "Suggestions: $suggestions"
        fi
        
        while true; do
            read -p "Enter correction for '$word' (or Enter to keep, 'q' to quit): " correction
            
            if [[ -z "$correction" ]]; then
                # Keep original word
                print_color $YELLOW "⚠️  Keeping original word: '$word'"
                break
            elif [[ "$correction" == "q" || "$correction" == "Q" ]]; then
                # Quit correction process
                print_color $YELLOW "⚠️  Correction cancelled"
                return 1
            else
                # Replace the word (case-insensitive replacement)
                local temp_corrected=$(echo "$corrected_message" | \
                                    sed -E "s/\b${word}\b/${correction}/gi")
                if [[ "$temp_corrected" != "$corrected_message" ]]; then
                    corrected_message="$temp_corrected"
                    changes_made=true
                    print_color $GREEN "✅ Updated: '$word' → '$correction'"
                    break
                else
                    print_color $RED "❌ Word '$word' not found in message. Please check spelling."
                fi
            fi
        done
    done
    
    if [[ "$changes_made" == "true" && "$corrected_message" != "$original_message" ]]; then
        echo
        print_color $GREEN "✅ Original message: $original_message"
        print_color $GREEN "✅ Corrected message: $corrected_message"
        echo
        
        # Ask if user wants to use the corrected message
        while true; do
            read -p "Use the corrected message? (y/n): " USE_CORRECTED
            case "$USE_CORRECTED" in
                y|Y|yes|YES)
                    # Store the corrected message in a global variable
                    CORRECTED_COMMIT_MSG="$corrected_message"
                    return 0
                    ;;
                n|N|no|NO)
                    print_color $YELLOW "⚠️  Using original message"
                    CORRECTED_COMMIT_MSG="$original_message"
                    return 0
                    ;;
                *)
                    print_color $RED "Please enter y (yes) or n (no)"
                    ;;
            esac
        done
    else
        print_color $YELLOW "⚠️  No changes made to the message"
        CORRECTED_COMMIT_MSG="$original_message"
        return 0
    fi
}

# Spell check function with correction capability
spell_check_commit_message() {
    local message="$1"
    local temp_file=$(mktemp)
    
    # Extract only the description part (after type/scope)
    local description=$(echo "$message" | sed -E 's/^[^:]*:[[:space:]]*//')
    
    if [[ -z "$description" ]]; then
        return 0  # No description to check
    fi
    
    # Remove emoji and special characters, split into words
    local words=$(echo "$description" | tr '[:upper:]' '[:lower:]' | \
                  sed -E 's/[^a-zA-Z0-9]/ /g' | tr ' ' '\n' | \
                  grep -E '^[a-z]{3,}' | sort -u)  # Only words 3+ chars long
    
    if [[ -z "$words" ]]; then
        return 0  # No words to check
    fi
    
    # Create a word list for spell checking
    echo "$words" > "$temp_file"
    
    local misspelled_words=()
    local has_aspell=$(command -v aspell >/dev/null 2>&1 && echo "yes" || echo "no")
    local has_hunspell=$(command -v hunspell >/dev/null 2>&1 && echo "yes" || echo "no")
    
    if [[ "$has_aspell" == "yes" ]]; then
        # Use aspell for spell checking
        misspelled_words=$(aspell list < "$temp_file" 2>/dev/null | sort -u)
    elif [[ "$has_hunspell" == "yes" ]]; then
        # Use hunspell for spell checking
        misspelled_words=$(hunspell -l < "$temp_file" 2>/dev/null | sort -u)
    else
        print_color $YELLOW "⚠️  No spell checker found (install aspell or hunspell for spell checking)"
        rm -f "$temp_file"
        return 0
    fi
    
    rm -f "$temp_file"
    
    # Filter out technical terms and very short words
    local final_misspelled=()
    for word in $misspelled_words; do
        if [[ ${#word} -ge 3 ]] && [[ -z "${TECHNICAL_TERMS[$word]}" ]]; then
            # Check if it's a camelCase or snake_case word
            if ! echo "$word" | grep -q -E '^[a-z]+([A-Z][a-z]+)+$' && \
               ! echo "$word" | grep -q -E '^[a-z]+_[a-z]+'; then
                final_misspelled+=("$word")
            fi
        fi
    done
    
    if [[ ${#final_misspelled[@]} -eq 0 ]]; then
        CORRECTED_COMMIT_MSG="$message"
        return 0
    else
        while true; do
            echo
            print_color $YELLOW "⚠️  Potential spelling issues found:"
            printf "   ${YELLOW}%s${NC}\n" "${final_misspelled[@]}"
            echo
            
            print_color $BLUE "Options:"
            echo "  c) Correct the message"
            echo "  i) Ignore and proceed"
            echo "  a) Abort commit"
            echo
            
            read -p "Choose action (c/i/a): " SPELL_CHOICE
            case "$SPELL_CHOICE" in
                c|C|correct)
                    correct_commit_message "$message" "${final_misspelled[@]}"
                        return 0  
                    ;;
                i|I|ignore)
                    print_color $YELLOW "⚠️  Spelling check ignored for this commit"
                    CORRECTED_COMMIT_MSG="$message"
                    return 0
                    ;;
                a|A|abort)
                    print_color $RED "❌ Commit aborted."
                    exit 1
                    ;;
                *)
                    print_color $RED "Please enter c (correct), i (ignore), or a (abort)"
                    ;;
            esac
        done
    fi
}

show_help() {
    print_color $GREEN "git-commit - Standardized Git Commit Script"
    echo
    print_color $BLUE "Usage:"
    echo "  git-commit <type-number> [scope] <description>"
    echo "  git-commit (interactive mode)"
    echo
    print_color $BLUE "Examples:"
    echo "  git-commit 1 auth \"add login feature\""
    echo "  git-commit 2 database \"fix connection pool leak\""
    echo "  git-commit 3 \"refactor user service\""
    echo
    print_color $BLUE "Available commit types:"
    for i in $(seq 1 8); do
        IFS=':' read -r type desc <<< "${TYPES[$i]}"
        printf "  ${YELLOW}%s${NC}) ${EMOJIS[$i]} ${GREEN}%-10s${NC} - %s\n" "$i" "$type" "$desc"
    done
    echo
    print_color $BLUE "Features:"
    echo "  • Automatic spell checking of commit messages"
    echo "  • Interactive spelling correction"
    echo "  • Technical term recognition"
    echo "  • Smart suggestions for misspelled words"
    echo
    print_color $BLUE "Options:"
    echo "  -h, --help        Show this help message"
    echo "  -v, --version     Show version information"
    echo "  -i, --interactive Interactive mode"
    echo "  --no-spellcheck   Disable spell checking"
    exit 0
}

show_version() {
    print_color $GREEN "git-commit v1.2.0"
    echo "A standardized git commit script with emojis, types, and spell checking"
    exit 0
}

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_color $RED "Error: Not a git repository"
        echo "Please run this script from within a git repository."
        exit 1
    fi
}

# Execute the git commit
execute_commit() {
    local commit_msg="$1"
    local display_msg="$2"
    local no_spellcheck="${3:-false}"
    
    while true; do
        # Spell checking (unless disabled)
        if [[ "$no_spellcheck" != "true" ]]; then
            local spell_result
            spell_check_commit_message "$commit_msg"
            spell_result=$?
            
            case $spell_result in
                0)  # Success - no issues or ignored
                    print_color $GREEN "✅ Spell check passed"
                    current_commit_msg="$CORRECTED_COMMIT_MSG"
                    ;;
                *)  # Abort
                    print_color $RED "❌ Commit aborted."
                    exit 1
                    ;;
            esac
        fi
        
        # Ask for final confirmation
        while true; do
            read -p "Proceed with commit? (y/N) " CONFIRM
            case "$CONFIRM" in
                y|Y|yes|YES)
                    if git commit -m "$CORRECTED_COMMIT_MSG"; then
                        print_color $GREEN "✅ Commit successful!"
                        echo "   Message: $CORRECTED_COMMIT_MSG"
                    else
                        print_color $RED "❌ Commit failed!"
                        exit 1
                    fi
                    return 0
                    ;;
                n|N|no|NO|"")
                    print_color $YELLOW "⚠️  Commit aborted."
                    exit 0
                    ;;
                *)
                    print_color $RED "Please enter y (yes) or n (no)"
                    ;;
            esac
        done
    done
}

# Interactive mode
interactive_mode() {
    local no_spellcheck="${1:-false}"
    
    print_color $GREEN "Interactive Git Commit Mode"
    echo
    
    # Show available types in order
    print_color $BLUE "Select commit type:"
    for i in $(seq 1 8); do
        IFS=':' read -r type desc <<< "${TYPES[$i]}"
        printf "  ${YELLOW}%s${NC}) ${EMOJIS[$i]} ${GREEN}%-10s${NC} - %s\n" "$i" "$type" "$desc"
    done
    
    # Get type selection
    while true; do
        echo
        read -p "Enter type number (1-8): " TYPE_NUM
        if [[ -n "${TYPES[$TYPE_NUM]}" ]]; then
            break
        else
            print_color $RED "Invalid selection. Please choose a number between 1-8."
        fi
    done
    
    # Get scope
    echo
    read -p "Enter scope (optional, press Enter to skip): " SCOPE
    
    # Get description
    echo
    while true; do
        read -p "Enter commit description: " DESCRIPTION
        if [[ -n "$DESCRIPTION" ]]; then
            break
        else
            print_color $RED "Description cannot be empty."
        fi
    done
    
    # Build commit messages
    IFS=':' read -r type desc <<< "${TYPES[$TYPE_NUM]}"
    local emoji="${EMOJIS[$TYPE_NUM]}"
    
    if [[ -n "$SCOPE" ]]; then
        COMMIT_MSG="$emoji $type($SCOPE): $DESCRIPTION"
        DISPLAY_MSG="$emoji $type($SCOPE): $DESCRIPTION"
    else
        COMMIT_MSG="$emoji $type: $DESCRIPTION"
        DISPLAY_MSG="$emoji $type: $DESCRIPTION"
    fi
    
    execute_commit "$COMMIT_MSG" "$DISPLAY_MSG" "$no_spellcheck"
}

# Main execution
main() {
    local no_spellcheck="false"
    
    # Parse flags first
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) show_help ;;
            -v|--version) show_version ;;
            -i|--interactive) 
                check_git_repo
                interactive_mode "$no_spellcheck"
                exit 0
                ;;
            --no-spellcheck)
                no_spellcheck="true"
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Handle empty arguments (interactive mode)
    if [[ $# -eq 0 ]]; then
        check_git_repo
        interactive_mode "$no_spellcheck"
        exit 0
    fi
    
    # Standard argument mode
    if [[ $# -lt 2 ]]; then
        print_color $RED "Error: Insufficient arguments"
        show_help
    fi
    
    check_git_repo
    
    TYPE_NUM=$1
    shift
    
    if [[ -z "${TYPES[$TYPE_NUM]}" ]]; then
        print_color $RED "Error: Invalid type number '$TYPE_NUM'"
        show_help
    fi
    
    # Parse arguments
    if [[ $# -gt 1 ]]; then
        SCOPE=$1
        shift
        DESCRIPTION="$*"
    else
        SCOPE=""
        DESCRIPTION="$*"
    fi
    
    # Build commit messages
    IFS=':' read -r type desc <<< "${TYPES[$TYPE_NUM]}"
    local emoji="${EMOJIS[$TYPE_NUM]}"
    
    if [[ -n "$SCOPE" ]]; then
        COMMIT_MSG="$emoji $type($SCOPE): $DESCRIPTION"
        DISPLAY_MSG="$emoji $type($SCOPE): $DESCRIPTION"
    else
        COMMIT_MSG="$emoji $type: $DESCRIPTION"
        DISPLAY_MSG="$emoji $type: $DESCRIPTION"
    fi
    
    execute_commit "$COMMIT_MSG" "$DISPLAY_MSG" "$no_spellcheck"
}

# Handle script interrupts
trap 'print_color $RED "\n⏹️  Script interrupted. Commit aborted."; exit 1' INT

# Run main function with all arguments
main "$@"
