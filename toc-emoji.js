const fs = require('fs');

const filepath = 'z:\\apimacc\\docs\\architecture\\data-architecture.md';
let content = fs.readFileSync(filepath, 'utf-8');

// ═══════════════════════════════════════════════════════════
// PART 1: Add Table of Contents after the title
// ═══════════════════════════════════════════════════════════

const toc = `
## 📑 Table of Contents

- [Section 1: Executive Summary](#section-1-executive-summary)
- [Section 2: Architecture Landscape](#section-2-architecture-landscape)
  - [2.1 Data Entities](#21-data-entities) · [2.2 Data Models](#22-data-models) · [2.3 Data Stores](#23-data-stores) · [2.4 Data Flows](#24-data-flows) · [2.5 Data Services](#25-data-services) · [2.6 Data Governance](#26-data-governance) · [2.7 Data Quality Rules](#27-data-quality-rules) · [2.8 Master Data](#28-master-data) · [2.9 Data Transformations](#29-data-transformations) · [2.10 Data Contracts](#210-data-contracts) · [2.11 Data Security](#211-data-security)
- [Section 3: Architecture Principles](#section-3-architecture-principles)
- [Section 4: Current State Baseline](#section-4-current-state-baseline)
- [Section 5: Component Catalog](#section-5-component-catalog)
  - [5.1 Data Entities](#51-data-entities) · [5.2 Data Models](#52-data-models) · [5.3 Data Stores](#53-data-stores) · [5.4 Data Flows](#54-data-flows) · [5.5 Data Services](#55-data-services) · [5.6 Data Governance](#56-data-governance) · [5.7 Data Quality Rules](#57-data-quality-rules) · [5.8 Master Data](#58-master-data) · [5.9 Data Transformations](#59-data-transformations) · [5.10 Data Contracts](#510-data-contracts) · [5.11 Data Security](#511-data-security)
- [Section 8: Dependencies & Integration](#section-8-dependencies--integration)

---
`;

// Handle both CRLF and LF
const nl = content.includes('\r\n') ? '\r\n' : '\n';
const tocFixed = toc.replace(/\n/g, nl);
content = content.replace(
  '# Data Architecture - APIM Accelerator' + nl,
  '# Data Architecture - APIM Accelerator' + nl + tocFixed
);

// ═══════════════════════════════════════════════════════════
// PART 2: Add emojis to table header cells
// ═══════════════════════════════════════════════════════════

// Emoji map for column headers
const emojiMap = {
  // Section 2 columns
  'Name': '📛 Name',
  'Description': '📝 Description',
  'Classification': '🏷️ Classification',
  
  // Section 3 columns
  'Principle': '💎 Principle',
  'Implementation': '🔧 Implementation',

  // Section 4 columns
  'Data Store': '🗄️ Data Store',
  'Type': '⚙️ Type',
  'Purpose': '🎯 Purpose',
  'Retention': '⏳ Retention',
  'Quality Dimension': '📊 Quality Dimension',
  'Current State': '📍 Current State',
  'Target State': '🎯 Target State',
  'Gap': '🔲 Gap',
  'Control': '🛡️ Control',
  'Status': '✅ Status',
  'Examples in Solution': '💡 Examples in Solution',

  // Section 5 columns
  'Component': '🧩 Component',
  'Storage': '💾 Storage',
  'Owner': '👤 Owner',
  'Freshness SLA': '⚡ Freshness SLA',
  'Source Systems': '📂 Source Systems',
  'Consumers': '🔗 Consumers',

  // Section 8 columns
  'Producer': '📤 Producer',
  'Consumer': '📥 Consumer',
  'Data': '📦 Data',
  'Flow Type': '🔄 Flow Type',
  'Contract': '📜 Contract',
};

const lines = content.split('\n');
for (let i = 0; i < lines.length; i++) {
  const line = lines[i];
  
  // Only process table header rows (starts with |, next line is separator)
  if (!line.startsWith('|')) continue;
  if (i + 1 >= lines.length) continue;
  if (!/^\|[\s\-:|]+\|/.test(lines[i + 1])) continue;
  
  // Skip if inside a mermaid block
  let inMermaid = false;
  for (let j = i - 1; j >= Math.max(0, i - 50); j--) {
    if (lines[j].trim() === '```mermaid') { inMermaid = true; break; }
    if (lines[j].trim() === '```') break;
  }
  if (inMermaid) continue;
  
  // Skip if already has emojis
  if (/[\u{1F300}-\u{1FFFF}]|[\u{2600}-\u{27BF}]/u.test(line)) continue;

  // Split and add emojis to each cell
  const cells = line.split('|');
  for (let c = 0; c < cells.length; c++) {
    const trimmed = cells[c].trim();
    if (trimmed && emojiMap[trimmed]) {
      cells[c] = cells[c].replace(trimmed, emojiMap[trimmed]);
    }
  }
  lines[i] = cells.join('|');
}

content = lines.join('\n');

fs.writeFileSync(filepath, content, 'utf-8');
console.log('Done. Added TOC and emojis to all table headers.');
