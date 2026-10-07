# SWE Inventory

| capability | owner+path | tier | how | spec | tests |
|---|---|---|---|---|---|
| telemetry intake | workers/telemetry/src/ (persistence.ts:86 fullfile_, worker.ts:31-41 bounded scan, types.ts:59-68 caps) | web-tier | operator procedure: quarantine+local-scan+sandbox-only, no auto-VT | runbook https://github.com/B67687/ithmb-codec-web/blob/main/docs/UPLOAD_HANDLING.md (codec repo https://github.com/B67687/ithmb-codec) | manual routine T5 |
