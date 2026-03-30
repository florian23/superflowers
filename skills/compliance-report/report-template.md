---
name: report-template
description: Instructions for generating the single-file HTML compliance report
---

# HTML Report Template Instructions

This document describes how to generate the compliance report HTML file. The report is a **single, self-contained HTML file** with all CSS, JavaScript, and chart libraries inlined.

## Structure

The generated HTML must follow this exact structure:

```html
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Compliance Report — YYYY-MM-DD</title>
  <style>
    /* ALL CSS HERE — see CSS section below */
  </style>
</head>
<body>
  <div id="app">
    <header id="executive-summary">
      <!-- Executive Summary section -->
    </header>

    <nav id="timeline">
      <!-- Interactive timeline -->
    </nav>

    <main id="content">
      <section id="trend-dashboard">
        <!-- Trend charts -->
      </section>

      <section id="feature-details">
        <!-- Collapsible feature sections -->
      </section>

      <section id="architecture-stability">
        <!-- FF timeline, BDD growth, ADR status, hotspots -->
      </section>

      <section id="drift-warnings">
        <!-- Drift warnings -->
      </section>

      <section id="recommendations">
        <!-- Recommendations -->
      </section>
    </main>
  </div>

  <script>
    // Chart.js library (minified, inlined)
    // IMPORTANT: Include the FULL Chart.js v4 UMD bundle here
    // Source: https://cdn.jsdelivr.net/npm/chart.js@4/dist/chart.umd.min.js
    // This MUST be inlined, not loaded from CDN
  </script>

  <script>
    // Compliance data as JSON
    const REPORT_DATA = {
      generatedAt: "YYYY-MM-DD",
      parameters: { feature: null, since: null },
      summary: {
        featuresAnalyzed: 0,
        averageScore: 0,
        trend: "stable", // "improving" | "stable" | "declining"
        keyFindings: []
      },
      features: [
        {
          name: "feature-name",
          startDate: "YYYY-MM-DD",
          endDate: "YYYY-MM-DD",
          commits: [],
          metrics: [
            // Generic array — one entry per loaded metric plugin
            // Each metric provides its own data shape
            {
              name: "metric-name",        // from frontmatter
              description: "...",          // from frontmatter
              weight: 1.0,                 // from frontmatter
              score: 0,                    // 0-100, null if descriptive-only
              checks: [                    // optional, for checklist-style metrics
                { name: "Check name", passed: true }
              ],
              data: {},                    // metric-specific data (free-form)
              warnings: [],                // metric-specific warnings
              visualization: "checklist"   // hint: "checklist" | "table" | "chart" | "mixed"
            }
          ]
        }
      ],
      trends: {
        complianceScores: [], // [{date, score, feature}]
        bddGrowth: [],        // [{date, totalScenarios}]
        hotspots: [],          // [{file, changeCount, features}]
        driftWarnings: []      // [{date, feature, type, message}]
      },
      warnings: [] // Global warnings (missing artifacts, shallow clone, etc.)
    };
  </script>

  <script>
    // Application JavaScript — see JS section below
  </script>
</body>
</html>
```

## CSS Design

### Color Palette
```css
:root {
  --color-bg: #0f1117;
  --color-surface: #1a1d27;
  --color-surface-hover: #242836;
  --color-border: #2d3244;
  --color-text: #e4e6ed;
  --color-text-muted: #8b8fa3;
  --color-accent: #6366f1;
  --color-accent-hover: #818cf8;
  --color-green: #22c55e;
  --color-yellow: #eab308;
  --color-red: #ef4444;
  --color-green-bg: rgba(34, 197, 94, 0.1);
  --color-yellow-bg: rgba(234, 179, 8, 0.1);
  --color-red-bg: rgba(239, 68, 68, 0.1);
}
```

### Design Principles
- **Dark theme** — professional, easy on the eyes for developer tools
- **Card-based layout** — each section in a card with subtle border and shadow
- **Generous spacing** — padding 1.5rem on cards, gap 1rem between elements
- **Monospace for data** — scores, dates, file paths in `font-family: 'JetBrains Mono', 'Fira Code', monospace`
- **Sans-serif for text** — headings and descriptions in `font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif`
- **Responsive** — CSS Grid with `grid-template-columns: repeat(auto-fit, minmax(300px, 1fr))`

### Score Color Coding
```css
.score-green { color: var(--color-green); background: var(--color-green-bg); }
.score-yellow { color: var(--color-yellow); background: var(--color-yellow-bg); }
.score-red { color: var(--color-red); background: var(--color-red-bg); }
```
- Green: score > 85
- Yellow: score 60-85
- Red: score < 60

### Collapsible Sections
```css
details.feature-card {
  border: 1px solid var(--color-border);
  border-radius: 8px;
  background: var(--color-surface);
  margin-bottom: 0.75rem;
}
details.feature-card summary {
  padding: 1rem 1.5rem;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
details.feature-card[open] summary {
  border-bottom: 1px solid var(--color-border);
}
```

## JavaScript Application

### Timeline Navigation

The timeline is a horizontal bar with clickable feature points:

```javascript
function renderTimeline(features) {
  // Create a horizontal container
  // For each feature: create a dot positioned proportionally by date
  // Dot color = score color (green/yellow/red)
  // Click handler: scrolls to feature detail and highlights it
  // Active dot gets a ring/glow effect
}
```

- Support keyboard navigation (left/right arrows)
- URL hash updates on navigation: `#feature=<name>`
- On page load, check URL hash and auto-navigate

### Charts (Chart.js)

All charts use Chart.js v4 with dark theme configuration:

```javascript
const chartDefaults = {
  color: '#8b8fa3',
  borderColor: '#2d3244',
  font: { family: "'JetBrains Mono', monospace" }
};

Chart.defaults.color = chartDefaults.color;
Chart.defaults.borderColor = chartDefaults.borderColor;
```

Required charts:
1. **Compliance Score Line Chart** — x: features (chronological), y: score 0-100
2. **Artifact Stacked Bar Chart** — x: features, y: check results (passed/failed stacked)
3. **BDD Growth Line Chart** — x: features, y: cumulative scenario count
4. **Code Impact Area Chart** — x: features, y: new files / modified files stacked
5. **Churn Ratio Line Chart** — x: features, y: churn ratio

### Feature Detail Rendering

Each feature gets a `<details>` element:

```javascript
function renderFeatureDetail(feature) {
  // Dynamically render all metrics from the generic array
  // Each metric's visualization hint determines the renderer
  const metricSections = feature.metrics
    .map(metric => renderMetric(metric))
    .join('');

  return `
    <details class="feature-card" id="feature-${feature.name}">
      <summary>
        <div class="feature-header">
          <span class="feature-name">${feature.name}</span>
          <span class="feature-date">${feature.startDate} → ${feature.endDate}</span>
        </div>
        <span class="score-badge ${scoreClass(feature.score)}">${feature.score}%</span>
      </summary>
      <div class="feature-body">
        ${metricSections}
        ${renderCommitTimeline(feature.commits)}
      </div>
    </details>
  `;
}

function renderMetric(metric) {
  // Generic metric renderer — dispatches based on visualization hint
  const renderers = {
    'checklist': renderChecklistMetric,
    'table': renderTableMetric,
    'chart': renderChartMetric,
    'mixed': renderMixedMetric
  };
  const render = renderers[metric.visualization] || renderMixedMetric;
  return `
    <div class="metric-section" data-metric="${metric.name}">
      <h4>${metric.description}</h4>
      ${metric.score !== null ? `<span class="score-badge ${scoreClass(metric.score)}">${metric.score}%</span>` : ''}
      ${render(metric)}
      ${metric.warnings.length > 0 ? renderMetricWarnings(metric.warnings) : ''}
    </div>
  `;
}
```

### Score Badge Helper

```javascript
function scoreClass(score) {
  if (score > 85) return 'score-green';
  if (score >= 60) return 'score-yellow';
  return 'score-red';
}
```

### Trend Calculation

```javascript
function calculateTrend(scores) {
  if (scores.length < 3) return 'stable';
  const recent = scores.slice(-3);
  const slope = (recent[2] - recent[0]) / 2;
  if (slope > 5) return 'improving';
  if (slope < -5) return 'declining';
  return 'stable';
}
```

### Deep Link Support

```javascript
window.addEventListener('hashchange', () => {
  const feature = location.hash.replace('#feature=', '');
  if (feature) {
    const el = document.getElementById(`feature-${feature}`);
    if (el) {
      el.open = true;
      el.scrollIntoView({ behavior: 'smooth' });
      highlightTimelineDot(feature);
    }
  }
});
```

## Report Sections Detail

### 1. Executive Summary
- Large score number (e.g., "82%") with color coding
- Trend arrow: ↗ improving, → stable, ↘ declining
- Feature count: "7 Features analysiert"
- Top 3 findings as bullet points
- Any global warnings (shallow clone, missing artifacts)

### 2. Timeline
- Horizontal bar spanning the date range
- One dot per feature, sized by impact level
- Dot color = compliance score color
- Hover tooltip: feature name + score
- Click = navigate to feature detail

### 3. Trend Dashboard
- 2-column grid of charts
- Compliance Score over time (primary chart, larger)
- BDD Growth, Code Impact, Churn as secondary charts

### 4. Feature Details
- One collapsible card per feature, sorted chronologically
- Summary line: name, date range, score badge
- Interior: Compliance checklist, Code impact table, Erosion alerts, Commit list

### 5. Architecture Stability
- FF Timeline: when were fitness functions changed?
- BDD Growth: cumulative scenario count
- ADR Status: accepted/superseded/deprecated counts
- Hotspot table: most-changed files across features

### 6. Drift Warnings
- Card per warning with severity icon
- Warning types: FF threshold lowered, BDD scenarios removed, Superseded ADR without successor
- Each warning links to the affected feature

### 7. Recommendations
- Generated from analysis findings
- Prioritized: critical (drift warnings) > medium (missing artifacts) > info (suggestions)
