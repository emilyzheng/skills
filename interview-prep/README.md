# interview-prep

Analyze a resume against a job description and generate a comprehensive interview preparation guide with skill matching, Q&A pairs, and a quick-reference cheat sheet.

## Installation

```bash
mkdir -p /path/to/your/project/.claude/skills/interview-prep
cp SKILL.md /path/to/your/project/.claude/skills/interview-prep/SKILL.md
```

Or install globally:

```bash
mkdir -p ~/.claude/skills/interview-prep
cp SKILL.md ~/.claude/skills/interview-prep/SKILL.md
```

## Usage

```
/interview-prep <resume_path> <job_description_path>
```

### Example

```
/interview-prep ./my-resume.pdf ./jd-senior-engineer.md
```

## Output

Writes `interview-prep-output.md` to the current directory containing:

- **Job Summary** — role overview and organizational context
- **Core Required Skills** — table mapping JD requirements to your experience
- **Business Context** — domain knowledge and terminology to study
- **Cross-Functional Collaboration** — teams and stakeholder relationships
- **Match Analysis** — strengths to emphasize and gaps to address
- **15 Interview Questions & Answers** — technical, behavioral, domain, and scenario-based, each with STAR-method reference answers
- **Quick Reference Card** — key talking points, questions to ask, and red flags to avoid
