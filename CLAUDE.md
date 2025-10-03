# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an ecological statistics course repository containing a comprehensive textbook on statistical methods for ecological data analysis. The project uses R Markdown with bookdown to generate multiple output formats including HTML, PDF, and EPUB.

## Key Files and Directories

- **Rmd files**: Main content files (e.g., `01-statistical_programing.Rmd`, `02-probability_and_distribution.Rmd`)
- **docs/**: Output directory containing generated HTML, PDF, and EPUB files
- **_bookdown.yml**: Configuration for bookdown build process
- **_output.yml**: Output format specifications
- **index.Rmd**: Book introduction and setup
- **build_slides.R**: Script to generate HTML slides from Rmd files
- **helper/**: Utility scripts for CDN link conversion
- **data/**: Data files used in examples
- **slides/**: Generated HTML slides

## Build System

### Building the Book

The main book is built using bookdown. Key commands:

```bash
# Build all formats (HTML, PDF, EPUB)
Rscript -e "bookdown::render_book('index.Rmd')"

# Build specific format
Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::gitbook')"
Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::pdf_book')"
Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::epub_book')"
```

### Individual File Testing

For testing individual Rmd files without the bookdown context:

```r
# Test a single file as HTML document (ignores YAML header issues)
rmarkdown::render("index.Rmd", output_format = "html_document")

# Test specific file with different formats
rmarkdown::render("01-statistical_programing.Rmd", output_format = "html_document")
rmarkdown::render("02-probability_and_distribution.Rmd", output_format = "pdf_document")
```

This approach is useful for quick testing of individual chapters while ignoring YAML header compatibility issues that may occur when rendering files outside the bookdown context.

### Generating Slides

To generate HTML slides from Rmd files:

```bash
# Run the slide generation script
Rscript build_slides.R
```

This processes all `.Rmd` files in the root directory and generates corresponding HTML slides in the `slides/` directory.

### Utility Scripts

- **helper/convert_cdn.R**: Converts CDN links in generated HTML files
- **build_slides.R**: Main slide generation script with preprocessing

## Content Structure

The book follows a progressive learning path:

1. **Statistical Programming Basics** (01-statistical_programing.Rmd)
2. **Probability and Distributions** (02-probability_and_distribution.Rmd)
3. **Summary Statistics** (03-summary_statistics.Rmd)
4. **Parameter Estimation** (04-parameter_estimation.Rmd)
5. **Correlation Analysis** (05-correlation.Rmd)
6. **Classical Hypothesis Tests** (06-classical_hypothesis_tests.Rmd)
7. **Simulation-based Tests** (07-simulation_based_tests.Rmd)
8. **Simple Linear Regression** (08-simple_linear_regressions.Rmd)
9. **Model Selection and Evaluation** (09-model_selection_and_evaluation.Rmd)
10. **Advanced Regression Models** (10-advanced_regressions.Rmd)
11. **Machine Learning** (11-machine_learning.Rmd)
12. **R Language Appendix** (15-Appendix1_R_language.Rmd)

## Development Workflow

1. **Edit Rmd files**: Modify content in the `.Rmd` files
2. **Build book**: Run bookdown to generate outputs
3. **Generate slides**: Optionally create slides for presentations
4. **Test outputs**: Verify HTML, PDF, and EPUB formats

## Dependencies

The project requires R with the following key packages:
- `bookdown`, `knitr`, `rmarkdown`
- `tidyverse`, `vegan`, `lme4`, `ggplot2`
- Various statistical and ecological analysis packages

See `index.Rmd` for the complete package list and installation instructions.

## Output Formats

- **HTML**: Interactive web version with navigation
- **PDF**: Printable book format with LaTeX typesetting
- **EPUB**: E-book format for mobile devices
- **Slides**: HTML presentations for teaching

## Language and Localization

The content is in Chinese with Chinese mathematical notation and terminology. The bookdown configuration includes Chinese labels for theorems, definitions, examples, and proofs.

## Writing Style

The book employs a distinctive writing style that combines:

**1. Literary and Poetic Expression**
- Rich use of metaphors and analogies: "embracing a world of dynamics, connections and uncertainty", "data oceans and natural chaos", "uncarved jade", "super intuition"
- Poetic descriptions: "clearly hearing the whispers of patterns", "most faithful companion and most reliable guide"

**2. Persuasive and Motivational Tone**
- Use of second-person "we" to create reader connection
- Emphatic vocabulary: "most powerful", "indispensable", "daring leap", "most faithful companion"
- Parallel structures for rhetorical impact: "First... then... finally..."

**3. Professional-Accessible Balance**
- Technical concepts explained through vivid metaphors: "carving knife", "digital telescope", "black box effect"
- Abstract statistical concepts grounded in concrete ecological scenarios like "butterfly migration" and "forest succession"

**4. Critical and Dialectical Thinking**
- Balanced analysis of technologies: "opportunities and pitfalls", "double-edged sword"
- Emphasis on critical evaluation: "must not become slaves to algorithms", "maintain deep skepticism toward model results"

**5. Educational Narrative Structure**
- Problem-oriented approach with progressive explanation of statistical necessity
- Integration of statistical thinking with ecologists' career development
- Focus on capability building rather than mere technical transmission

This style maintains academic rigor while using engaging language and analogies to make abstract statistical concepts accessible, reflecting the characteristics of excellent educational writing.

## Writing Requirements

**1. Paragraph-Based Structure**
- Avoid excessive use of bullet-point lists suitable for presentations
- Prefer logically structured paragraphs for book-style content
- Ensure smooth transitions between ideas within coherent paragraphs

**2. Concise and Clear Expression**
- Use short, logically coherent sentences
- Avoid overly lengthy language structures
- Maintain clarity while ensuring professional depth

**3. Mathematical Notation Standards**
- All variables and formulas must use LaTeX format
- Mathematical expressions should be properly formatted with appropriate delimiters
- Ensure consistency in mathematical notation throughout the book

**4. R Code Standards**

**4.1 Code Organization**
- Each R chunk should be around 30 lines maximum
- Split longer code into multiple logical chunks
- Use text paragraphs between chunks to explain relationships and provide detailed explanations

**4.2 Line Length and Formatting**
- Maximum line length of 80 characters
- Break long lines appropriately for readability

**4.3 Example Data Management**
- If example data preparation requires more than 3 lines, place in separate chunk
- Set `echo=FALSE` for data preparation chunks
- Save example data as `.rda` files in the `data/` directory
- Load data using `load()` in subsequent chunks

**4.4 Code Comments**
- Comment every line of code explaining its function
- Reference relevant text descriptions from preceding paragraphs
- Connect code implementation with theoretical concepts

**4.5 Output Formatting**
- Avoid multiple consecutive `cat()` or `print()` functions
- Use single `cat()` with multi-line text for grouped output

**4.6 Figure Generation**
- Set `fig.cap` parameter for all figure-generating chunks
- Generate appropriate captions based on context
- Avoid multiple figures in single chunk
- Split multi-figure code into separate chunks with individual `fig.cap` settings
- All r chunks with figure generation must have an id for cross reference 
- All figures (both R-generated and imported) must be referenced in nearby paragraphs