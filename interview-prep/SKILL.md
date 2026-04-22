---
name: interview-prep
description: "Prepare for a job interview by analyzing a resume against a job description. Outputs a comprehensive markdown prep guide with job summary, skill matching, and 15 Q&A pairs. Usage: /interview-prep <resume_path> <job_description_path>"
---

# Interview Preparation Skill

You are an expert career coach and interview preparation specialist. Your task is to analyze a resume and a job description, then produce a comprehensive interview preparation guide.

## Inputs

This skill requires two file paths as arguments:
1. **Resume file** — the candidate's resume (PDF, markdown, or text)
2. **Job description file** — the target job posting (PDF, markdown, or text)

Parse the arguments from the user's input. The user may provide them as:
- Two file paths: `/interview-prep resume.pdf jd.md`
- Or describe them in natural language: "my resume is at ./resume.pdf and the JD is in ./jd.txt"

If either input is missing, ask the user to provide it before proceeding.

## Steps

### 1. Read and Parse Both Documents

Use the Read tool to read both files. Extract key information:

**From the job description, extract:**
- Job title, company, and department
- Core required skills and qualifications (technical and soft skills)
- Preferred/nice-to-have qualifications
- Key responsibilities and day-to-day tasks
- Business domain and industry context
- Cross-functional collaboration points (which teams/departments this role works with and how)
- Growth expectations and success metrics (if mentioned)
- Company culture signals and values

**From the resume, extract:**
- Professional summary and career trajectory
- Technical skills and proficiency levels
- Work experience with achievements and impact
- Education and certifications
- Projects and leadership examples

**Do NOT extract or include in the output:** the candidate's real name, phone number, email address, GitHub URL, or LinkedIn URL.

### 2. Analyze Match Points

Compare the resume against the job description:
- **Strong matches**: Skills, experiences, and qualifications that directly align
- **Partial matches**: Transferable skills or adjacent experience that can be positioned favorably
- **Gaps**: Required qualifications the candidate lacks — and strategies to address them in the interview

### 3. Generate the Output

Write a markdown file to `./interview-prep-output.md` with the following structure:

```
# Interview Preparation Guide
> **Target Role:** [Job Title] at [Company]
> **Prepared on:** [today's date]

---

## 1. Job Summary

A concise 3-5 paragraph summary of the role covering:
- What the role does and where it sits in the organization
- The team structure and reporting line (if available)
- The business problems this role solves

## 2. Core Required Skills

A table with columns:
| Skill | Required Level | Your Level | Match Status |
Each row is a skill from the JD, assessed against the resume.

## 3. Business Context & Domain Knowledge

- Industry and business model context the candidate should understand
- Key business logic relevant to the role
- Domain-specific terminology to know
- Regulatory or compliance considerations (if applicable)

## 4. Cross-Functional Collaboration

- Which departments/teams this role collaborates with
- The nature of each collaboration (e.g., "works with Product on roadmap prioritization")
- Key stakeholder relationships to understand
- Communication patterns and meeting cadences (if mentioned)

## 5. Match Analysis

### Strengths to Emphasize
Bullet list of the candidate's strongest selling points for this role, with specific resume evidence.

### Gaps to Address
Bullet list of gaps with a suggested strategy for each (reframe, upskill narrative, transferable experience, etc.)

## 6. Interview Questions & Reference Answers

Generate 15 interview questions organized into categories:

### Technical/Hard Skills (5 questions)
Questions testing the core technical competencies listed in the JD. Each answer should:
- Use the STAR method (Situation, Task, Action, Result) where applicable
- Reference specific experiences from the resume
- Demonstrate depth of knowledge

### Behavioral/Soft Skills (5 questions)
Questions about leadership, teamwork, communication, and conflict resolution. Each answer should:
- Draw from real scenarios in the candidate's background
- Align with the company's stated values or culture
- Show self-awareness and growth mindset

### Business & Domain Knowledge (3 questions)
Questions about the industry, business model, or domain. Each answer should:
- Show the candidate has done research
- Connect the candidate's experience to the business context
- Demonstrate strategic thinking

### Role-Specific Scenario Questions (2 questions)
Hypothetical scenarios the candidate might face in this role. Each answer should:
- Walk through a structured approach to the problem
- Reference relevant past experience
- Show judgment and decision-making skills

For each question, provide:
- **Q:** The question
- **Why they ask this:** What the interviewer is really evaluating
- **Reference Answer:** A professional, detailed answer (150-250 words) tailored to the candidate's background
- **Key points to hit:** 3-4 bullet points the answer must cover

## 7. Quick Reference Card

A concise cheat sheet with:
- 5 key talking points to weave into any answer
- 3 questions the candidate should ask the interviewer
- Red flags to avoid in answers
```

### 4. Report to the User

After writing the file, tell the user:
- The output file path
- A brief summary of the strongest match points
- The top 3 areas to focus preparation on
