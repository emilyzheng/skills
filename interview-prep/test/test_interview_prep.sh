#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"
WORK_DIR=$(mktemp -d)

cleanup() {
    rm -rf "$WORK_DIR"
}
trap cleanup EXIT

PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); echo "  PASS: $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  FAIL: $1"; }

check_section() {
    local file="$1" pattern="$2" label="$3"
    if grep -qi "$pattern" "$file"; then
        pass "$label"
    else
        fail "$label — pattern '$pattern' not found"
    fi
}

echo "=== interview-prep skill test ==="
echo ""
echo "Work directory: $WORK_DIR"
echo "Fixtures: $FIXTURES_DIR"
echo ""

# --- Pre-flight checks ---
echo "[1/4] Pre-flight checks"

if ! command -v claude &>/dev/null; then
    echo "ERROR: claude CLI not found in PATH"
    exit 1
fi
pass "claude CLI available"

if [[ ! -f "$FIXTURES_DIR/resume.txt" ]]; then
    echo "ERROR: resume fixture missing"
    exit 1
fi
if [[ ! -f "$FIXTURES_DIR/jd.txt" ]]; then
    echo "ERROR: JD fixture missing"
    exit 1
fi
pass "fixtures exist"

echo ""

# --- Run the skill ---
echo "[2/4] Running /interview-prep (this will take a minute or two)..."

cd "$WORK_DIR"
claude -p "/interview-prep $FIXTURES_DIR/resume.txt $FIXTURES_DIR/jd.txt" \
    --allowedTools "Read,Write,Edit" \
    --max-turns 20 \
    > "$WORK_DIR/claude-output.txt" 2>&1

CLAUDE_EXIT=$?
if [[ $CLAUDE_EXIT -ne 0 ]]; then
    fail "claude exited with code $CLAUDE_EXIT"
    echo "--- claude output ---"
    cat "$WORK_DIR/claude-output.txt"
    echo "--- end ---"
else
    pass "claude exited successfully"
fi

echo ""

# --- Check output file exists ---
echo "[3/4] Checking output file"

OUTPUT_FILE="$WORK_DIR/interview-prep-output.md"
if [[ ! -f "$OUTPUT_FILE" ]]; then
    fail "interview-prep-output.md was not created"
    echo ""
    echo "--- claude output ---"
    cat "$WORK_DIR/claude-output.txt"
    echo "--- end ---"
    echo ""
    echo "=== Results: $PASS passed, $FAIL failed ==="
    exit 1
fi
pass "interview-prep-output.md exists"

FILE_SIZE=$(wc -c < "$OUTPUT_FILE" | tr -d ' ')
if [[ $FILE_SIZE -gt 1000 ]]; then
    pass "output file is substantial (${FILE_SIZE} bytes)"
else
    fail "output file too small (${FILE_SIZE} bytes), expected >1000"
fi

echo ""

# --- Validate required sections ---
echo "[4/4] Validating content structure"

check_section "$OUTPUT_FILE" "Interview Preparation Guide" "title present"
check_section "$OUTPUT_FILE" "Job Summary" "section 1: Job Summary"
check_section "$OUTPUT_FILE" "Core Required Skills" "section 2: Core Required Skills"
check_section "$OUTPUT_FILE" "Business Context" "section 3: Business Context"
check_section "$OUTPUT_FILE" "Cross-Functional Collaboration" "section 4: Cross-Functional Collaboration"
check_section "$OUTPUT_FILE" "Match Analysis" "section 5: Match Analysis"
check_section "$OUTPUT_FILE" "Strengths to Emphasize" "section 5a: Strengths to Emphasize"
check_section "$OUTPUT_FILE" "Gaps to Address" "section 5b: Gaps to Address"
check_section "$OUTPUT_FILE" "Interview Questions" "section 6: Interview Questions"
check_section "$OUTPUT_FILE" "Quick Reference Card" "section 7: Quick Reference Card"

# Check the skills table has the expected markdown table format
if grep -q '|.*Skill.*|.*Required Level.*|.*Your Level.*|.*Match Status.*|' "$OUTPUT_FILE" 2>/dev/null || \
   grep -qi '| Skill' "$OUTPUT_FILE" 2>/dev/null; then
    pass "skills comparison table present"
else
    fail "skills comparison table not found"
fi

# Check question categories
check_section "$OUTPUT_FILE" "Technical.*Skills\|Hard Skills" "question category: Technical/Hard Skills"
check_section "$OUTPUT_FILE" "Behavioral.*Skills\|Soft Skills" "question category: Behavioral/Soft Skills"
check_section "$OUTPUT_FILE" "Business.*Domain\|Domain Knowledge" "question category: Business & Domain Knowledge"
check_section "$OUTPUT_FILE" "Scenario" "question category: Scenario Questions"

# Count questions (look for Q: or **Q** patterns)
Q_COUNT=$(grep -cE '^\*\*Q[0-9]*[:.]|\*\*Q:\*\*|^Q[0-9]*[:.]' "$OUTPUT_FILE" 2>/dev/null || echo 0)
if [[ $Q_COUNT -ge 15 ]]; then
    pass "at least 15 questions found ($Q_COUNT)"
elif [[ $Q_COUNT -ge 10 ]]; then
    fail "only $Q_COUNT questions found (expected 15) — close but short"
else
    # Try alternative patterns — the format may vary
    Q_COUNT_ALT=$(grep -ciE '\*\*Q[0-9]*' "$OUTPUT_FILE" 2>/dev/null || echo 0)
    if [[ $Q_COUNT_ALT -ge 15 ]]; then
        pass "at least 15 questions found ($Q_COUNT_ALT, alt pattern)"
    else
        fail "only $Q_COUNT/$Q_COUNT_ALT questions found (expected 15)"
    fi
fi

# Check for key sub-fields per question
check_section "$OUTPUT_FILE" "Why they ask this" "per-question: 'Why they ask this' field"
check_section "$OUTPUT_FILE" "Reference Answer" "per-question: 'Reference Answer' field"
check_section "$OUTPUT_FILE" "Key points to hit" "per-question: 'Key points to hit' field"

# Check Quick Reference Card sub-sections
check_section "$OUTPUT_FILE" "talking points\|key.*talking" "quick ref: talking points"
check_section "$OUTPUT_FILE" "questions.*ask.*interviewer\|ask the interviewer" "quick ref: questions to ask"
check_section "$OUTPUT_FILE" "red flags\|flags to avoid" "quick ref: red flags to avoid"

# Check that personal info is NOT in the output
if grep -qi "Apple Pineapple" "$OUTPUT_FILE"; then
    fail "output contains candidate name — should be excluded"
else
    pass "candidate name excluded from output"
fi
if grep -qi "apple\.pineapple@email\.com" "$OUTPUT_FILE"; then
    fail "output contains candidate email — should be excluded"
else
    pass "candidate email excluded from output"
fi
if grep -qi "fakegit\.com/applepineapple" "$OUTPUT_FILE"; then
    fail "output contains candidate GitHub URL — should be excluded"
else
    pass "candidate GitHub URL excluded from output"
fi
if grep -qi "fakelink\.com/applepineapple" "$OUTPUT_FILE"; then
    fail "output contains candidate LinkedIn URL — should be excluded"
else
    pass "candidate LinkedIn URL excluded from output"
fi

# Check that content is personalized to the fixtures (not generic)
if grep -qi "Acme Corp\|DataFlow" "$OUTPUT_FILE"; then
    pass "content references resume details"
else
    fail "content does not reference resume details — may be generic"
fi

if grep -qi "YYY\|fintech\|Platform Infrastructure\|Staff Software Engineer" "$OUTPUT_FILE"; then
    pass "content references JD details"
else
    fail "content does not reference JD details — may be generic"
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
