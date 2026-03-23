import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { exec } from 'child_process';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const ROOT_DIR = path.resolve(__dirname, '../src');
const CONFIG_PATH = path.resolve(__dirname, '../config/visual-design-foundations.json');
const REPORT_DIR = path.resolve(__dirname, '../reports');

// Ensure report directory exists
if (!fs.existsSync(REPORT_DIR)) {
  fs.mkdirSync(REPORT_DIR);
}

// Colors to flag (hardcoded hex values)
const HARDCODED_COLOR_REGEX = /#(?:[0-9a-fA-F]{3}){1,2}\b/g;

// Load config
let config = {};
try {
  if (fs.existsSync(CONFIG_PATH)) {
    const configFile = fs.readFileSync(CONFIG_PATH, 'utf8');
    config = JSON.parse(configFile);
  } else {
    console.warn('Warning: visual-design-foundations.json not found.');
  }
} catch (e) {
  console.warn('Warning: Failed to parse visual-design-foundations.json');
}

const IGNORE_FILES = ['vite-env.d.ts', 'index.css'];

function scanFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const issues = [];
  const lines = content.split('\n');

  // Check for hardcoded colors
  let match;
  while ((match = HARDCODED_COLOR_REGEX.exec(content)) !== null) {
    // Ignore if it's in the config file itself or checking for it
    if (!config.colors || !JSON.stringify(config.colors).includes(match[0])) {
      const lineNum = content.substring(0, match.index).split('\n').length;
      issues.push({
        type: 'Hardcoded Color',
        value: match[0],
        line: lineNum,
        severity: 'P2', // Default to P2 for hardcoded colors
        code: lines[lineNum - 1].trim()
      });
    }
  }

  return issues;
}

function walkDir(dir, fileList = []) {
  if (!fs.existsSync(dir)) return fileList;
  const files = fs.readdirSync(dir);
  files.forEach(file => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    if (stat.isDirectory()) {
      walkDir(filePath, fileList);
    } else {
      if ((filePath.endsWith('.tsx') || filePath.endsWith('.ts') || filePath.endsWith('.css')) && !IGNORE_FILES.includes(file)) {
        fileList.push(filePath);
      }
    }
  });
  return fileList;
}

console.log('🔍 Starting Visual Design Validation...');
const files = walkDir(ROOT_DIR);
let allIssues = [];

files.forEach(file => {
  const issues = scanFile(file);
  if (issues.length > 0) {
    const relativePath = path.relative(ROOT_DIR, file);
    issues.forEach(issue => {
      allIssues.push({
        file: relativePath,
        ...issue
      });
    });
  }
});

// Calculate stats
const totalIssues = allIssues.length;
const p0Count = allIssues.filter(i => i.severity === 'P0').length;
const p1Count = allIssues.filter(i => i.severity === 'P1').length;

// Generate Markdown Report
let reportMd = '# Visual Design Validation Report\n\n';
reportMd += `**Date:** ${new Date().toLocaleString()}\n`;
reportMd += `**Total Issues:** ${totalIssues} (P0: ${p0Count}, P1: ${p1Count})\n\n`;

if (totalIssues > 0) {
  reportMd += '| File | Line | Type | Value | Severity |\n|---|---|---|---|---|\n';
  allIssues.forEach(issue => {
    reportMd += `| ${issue.file} | ${issue.line} | ${issue.type} | \`${issue.value}\` | ${issue.severity} |\n`;
  });
} else {
  reportMd += '✅ No visual design issues found.\n';
}

const mdPath = path.resolve(REPORT_DIR, 'visual-report.md');
fs.writeFileSync(mdPath, reportMd);

// Generate HTML Report
let reportHtml = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Visual Validation Report</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; padding: 2rem; max-width: 1200px; margin: 0 auto; color: #1f2937; }
    h1 { color: #111827; border-bottom: 2px solid #e5e7eb; padding-bottom: 0.5rem; }
    .summary { display: flex; gap: 1rem; margin-bottom: 2rem; }
    .card { padding: 1rem; border-radius: 0.5rem; border: 1px solid #e5e7eb; flex: 1; text-align: center; }
    .card.total { background-color: #f3f4f6; }
    .card.p0 { background-color: #fee2e2; border-color: #fca5a5; color: #991b1b; }
    .card.p1 { background-color: #ffedd5; border-color: #fdba74; color: #9a3412; }
    .card.p2 { background-color: #fef9c3; border-color: #fde047; color: #854d0e; }
    .count { font-size: 2rem; font-weight: bold; display: block; }
    table { width: 100%; border-collapse: collapse; margin-top: 1rem; box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1); }
    th { background-color: #f9fafb; text-align: left; padding: 0.75rem 1rem; font-weight: 600; border-bottom: 1px solid #e5e7eb; }
    td { padding: 0.75rem 1rem; border-bottom: 1px solid #e5e7eb; }
    tr:hover { background-color: #f9fafb; }
    .badge { padding: 0.25rem 0.5rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 500; }
    .badge-P0 { background-color: #fee2e2; color: #991b1b; }
    .badge-P1 { background-color: #ffedd5; color: #9a3412; }
    .badge-P2 { background-color: #fef9c3; color: #854d0e; }
    code { background-color: #f3f4f6; padding: 0.2rem 0.4rem; border-radius: 0.25rem; font-family: monospace; font-size: 0.875rem; }
    .file-path { color: #4b5563; font-size: 0.875rem; }
  </style>
</head>
<body>
  <h1>Visual Design Validation Report</h1>
  <div class="summary">
    <div class="card total"><span class="count">${totalIssues}</span>Total Issues</div>
    <div class="card p0"><span class="count">${p0Count}</span>P0 (Critical)</div>
    <div class="card p1"><span class="count">${p1Count}</span>P1 (High)</div>
  </div>

  <table>
    <thead>
      <tr>
        <th>Severity</th>
        <th>File</th>
        <th>Line</th>
        <th>Issue</th>
        <th>Value</th>
        <th>Context</th>
      </tr>
    </thead>
    <tbody>
`;

if (allIssues.length > 0) {
  allIssues.forEach(issue => {
    reportHtml += `
      <tr>
        <td><span class="badge badge-${issue.severity}">${issue.severity}</span></td>
        <td class="file-path">${issue.file}</td>
        <td>${issue.line}</td>
        <td>${issue.type}</td>
        <td><code>${issue.value}</code></td>
        <td style="color: #6b7280; font-family: monospace; font-size: 0.8em;">${issue.code.replace(/</g, '&lt;').replace(/>/g, '&gt;').substring(0, 50)}${issue.code.length > 50 ? '...' : ''}</td>
      </tr>
    `;
  });
} else {
  reportHtml += `<tr><td colspan="6" style="text-align: center; padding: 2rem;">✅ No visual design issues found. Great job!</td></tr>`;
}

reportHtml += `
    </tbody>
  </table>
  <p style="margin-top: 2rem; color: #6b7280; font-size: 0.875rem;">Generated at ${new Date().toLocaleString()}</p>
</body>
</html>
`;

const htmlPath = path.resolve(REPORT_DIR, 'visual-report.html');
fs.writeFileSync(htmlPath, reportHtml);

console.log(`\n✨ Scan complete. Found ${totalIssues} potential issues.`);
console.log(`📄 Markdown Report: ${mdPath}`);
console.log(`📄 HTML Report: ${htmlPath}`);

// Open in browser if --open flag is present
const args = process.argv.slice(2);
if (args.includes('--open')) {
  console.log('🌍 Opening HTML report in browser...');
  const start = (process.platform == 'darwin' ? 'open' : process.platform == 'win32' ? 'start' : 'xdg-open');
  exec(`${start} "${htmlPath}"`);
}

// Fail if P0/P1 issues found
if (p0Count > 0 || p1Count > 0) {
  console.error('\n❌ Critical visual design issues found (P0/P1)!');
  process.exit(1);
}
