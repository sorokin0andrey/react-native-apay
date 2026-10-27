const {execFileSync} = require('node:child_process');

const required = [
  'package.json',
  'README.md',
  'LICENSE',
  'index.js',
  'index.d.ts',
  'src/NativeRNApplePay.ts',
  'ios/RNApplePay.h',
  'ios/RNApplePay.mm',
  'ios/RNApplePayImpl.swift',
  'RNApplePay.podspec',
  'react-native.config.js',
];

execFileSync(process.execPath, ['--check', 'index.js'], {stdio: 'inherit'});

const output = execFileSync('npm', ['pack', '--dry-run', '--json'], {
  encoding: 'utf8',
});
const packed = JSON.parse(output);
const files = packed[0].files.map(file => file.path);
const included = new Set(files);

const missing = required.filter(path => !included.has(path));
if (missing.length > 0) {
  console.error(`Missing from the npm package:\n${missing.join('\n')}`);
  process.exit(1);
}

const forbidden = files.filter(
  path =>
    path.startsWith('Example/') ||
    path.startsWith('example/') ||
    path.startsWith('node_modules/') ||
    path === 'preview.gif' ||
    path === 'preview.mp4' ||
    path === 'simulator.gif',
);
if (forbidden.length > 0) {
  console.error(`Unexpected files in the npm package:\n${forbidden.join('\n')}`);
  process.exit(1);
}

console.log(`${packed[0].filename} is ready (${files.length} files).`);
