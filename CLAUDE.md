# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Quarto-based course website for PSC 2339 - Comparative Political Economy at The George Washington University. The site is published at https://www.psc2339.com and contains course materials including weekly schedules, lecture slides, assignments, and project information.

## Building and Development

### Preview the Website
```bash
quarto preview
```

### Render the Full Site
```bash
quarto render
```

### Render Specific Files
```bash
quarto render path/to/file.qmd
```

### Publish to Web
```bash
quarto publish
```

## Content Architecture

### Site Configuration
- `_quarto.yml` - Main configuration file controlling website structure, theme, navigation, and sidebar
  - Defines the course schedule and all navigational elements
  - Controls visual theme (cosmo light/cyborg dark with Atkinson Hyperlegible font)
  - Lists all course sections: information, project assignments, and weekly materials

### Content Organization

**Core Course Files** (root directory):
- `index.qmd` - Course schedule table (uses R code to generate dates dynamically from start date)
- `course-syllabus.qmd` - Full syllabus with learning objectives, assignments, grading
- `course-description.qmd`, `course-links.qmd`, `course-support.qmd` - Supplementary course info
- `instructor.qmd` - Instructor information
- `faq.qmd` - Frequently asked questions

**Weekly Materials** (`weeks/`):
- Files named `week-1.qmd` through `week-15.qmd`
- Each contains readings and links to corresponding lecture slides

**Lecture Slides** (`slides/`):
- Revealjs presentation format files
- Named `lecture-X.Y.qmd` (e.g., `lecture-2.1.qmd`, `lecture-7.2.qmd`)
- Include embedded R code for data visualizations
- Use custom theme (moon) with fade transitions

**Project Assignments** (`project/`):
- `project-assignment-1.qmd` - Outline and sources
- `project-assignment-2.qmd` - Proposal and data cleaning
- `project-assignment-3.qmd` - Final dashboard submission
- `project-datasets.qmd` - Available datasets for student projects

**Data Assignments** (`assignments/`):
- `data-assignment-1.qmd`, `data-assignment-2.qmd` - Excel-based data analysis assignments

### Dynamic Date Generation

The course schedule in `index.qmd` uses R code to calculate dates:
```r
tue <- as_date("2025-01-13")  # Semester start date
thur <- tue+days(2)
advdate <- function(day, week) {...}  # Generates dates for each week
```

To update the course schedule for a new semester, only change the `tue` date in `index.qmd`.

### Lecture Slides with Data Visualizations

Lecture slides frequently include R code chunks for:
- Interactive Plotly visualizations
- Data analysis using tidyverse
- Economic/political data from FRED API
- Custom recession shading functions

Example from `lecture-1.qmd`: includes a complex commercial paper rates visualization using FRED data with recession shading.

## Content Guidelines

### When Creating New Course Materials

**New Weekly Material**:
- Create `weeks/week-X.qmd` following existing pattern
- Add to `_quarto.yml` sidebar under "Weekly materials" section

**New Lecture Slides**:
- Use Revealjs format with moon theme
- Include frontmatter with title, subtitle, author, footer with website link, and logo
- R code chunks should have `echo: false` and `freeze: auto`

**New Project/Assignment**:
- Place in appropriate directory (`project/` or `assignments/`)
- Update `_quarto.yml` if it should appear in navigation

### File Naming Conventions

- Weekly materials: `week-X.qmd` (X = week number)
- Lecture slides: `lecture-X.Y.qmd` (X = week, Y = lecture number within week)
- Project assignments: `project-assignment-X.qmd`
- Data assignments: `data-assignment-X.qmd`

## Key Dependencies

This site requires:
- **Quarto** - Document publishing system
- **R** - For dynamic content and data visualizations
- **R packages**: lubridate, tidyverse, plotly, scales, ecm, fredr, htmlwidgets
- FRED API key (stored in environment variable `FRED_API_KEY`) for economic data

## Attribution

Based on a template by Mine Çetinkaya-Rundel. Licensed under Creative Commons Attribution-NonCommercial 4.0 International License.
