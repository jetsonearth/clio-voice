2025-08-15T13:20:57Z app[5683970eae6308] sin [info]POST /api/asr/temp-key - 200 (1117ms)
2025-08-15T13:20:58Z app[5683970eae6308] sin [info]❌ [FLY-LLM] Proxy error: DOMException [AbortError]: This operation was aborted
2025-08-15T13:20:58Z app[5683970eae6308] sin [info]    at node:internal/deps/undici/undici:12637:11
2025-08-15T13:20:58Z app[5683970eae6308] sin [info]    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
2025-08-15T13:20:58Z app[5683970eae6308] sin [info]    at async llmProxy (file:///app/src/routes/llm.js:78:26)
2025-08-15T13:20:58Z app[5683970eae6308] sin [info]file:///app/src/routes/llm.js:145
2025-08-15T13:20:58Z app[5683970eae6308] sin [info]      res.setHeader('X-Flex-Timeout-MS', String(FLEX_TIMEOUT_MS));
2025-08-15T13:20:58Z app[5683970eae6308] sin [info]                                                ^
2025-08-15T13:20:58Z app[5683970eae6308] sin [info]ReferenceError: FLEX_TIMEOUT_MS is not defined
2025-08-15T13:20:58Z app[5683970eae6308] sin [info]    at llmProxy (file:///app/src/routes/llm.js:145:49)
2025-08-15T13:20:58Z app[5683970eae6308] sin [info]    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
2025-08-15T13:20:58Z app[5683970eae6308] sin [info]Node.js v18.20.8
2025-08-15T13:20:58Z proxy[5683970eae6308] sin [error][PU02] could not complete HTTP request to instance: connection closed before message completed
2025-08-15T13:20:58Z app[5683970eae6308] sin [info]npm notice
2025-08-15T13:20:58Z app[5683970eae6308] sin [info]npm notice New major version of npm available! 10.8.2 -> 11.5.2
2025-08-15T13:20:58Z app[5683970eae6308] sin [info]npm notice Changelog: https://github.com/npm/cli/releases/tag/v11.5.2
2025-08-15T13:20:58Z app[5683970eae6308] sin [info]npm notice To update run: npm install -g npm@11.5.2
2025-08-15T13:20:58Z app[5683970eae6308] sin [info]npm notice
2025-08-15T13:20:59Z app[5683970eae6308] sin [info] INFO Main child exited normally with code: 1
2025-08-15T13:20:59Z app[5683970eae6308] sin [info] INFO Starting clean up.
2025-08-15T13:20:59Z app[5683970eae6308] sin [info] WARN could not unmount /rootfs: EINVAL: Invalid argument
2025-08-15T13:20:59Z app[5683970eae6308] sin [info][  447.219479] reboot: Restarting system
2025-08-15T13:20:59Z app[5683970eae6308] sin [info]2025-08-15T13:20:59.849420722 [01K2A5BMF9XXQBYHK379ZN3EVM:main] Running Firecracker v1.12.1
2025-08-15T13:20:59Z app[5683970eae6308] sin [info]2025-08-15T13:20:59.849557864 [01K2A5BMF9XXQBYHK379ZN3EVM:main] Listening on API socket ("/fc.sock").
2025-08-15T13:21:00Z app[5683970eae6308] sin [info] INFO Starting init (commit: 6c3309ba)...
2025-08-15T13:21:00Z app[5683970eae6308] sin [info] INFO Preparing to run: `docker-entrypoint.sh npm start` as nodejs
2025-08-15T13:21:00Z app[5683970eae6308] sin [info] INFO [fly api proxy] listening at /.fly/api
2025-08-15T13:21:00Z runner[5683970eae6308] sin [info]Machine started in 831ms
2025-08-15T13:21:00Z app[5683970eae6308] sin [info]2025/08/15 13:21:00 INFO SSH listening listen_address=[fdaa:25:25c4:a7b:4ff:9914:1cd8:2]:22
2025-08-15T13:21:01Z app[5683970eae6308] sin [info]> clio-flyio-api@1.0.0 start
2025-08-15T13:21:01Z app[5683970eae6308] sin [info]> node src/index.js
2025-08-15T13:21:01Z app[5683970eae6308] sin [info]⚠️  Node.js 18 and below are deprecated and will no longer be supported in future versions of @supabase/supabase-js. Please upgrade to Node.js 20 or later. For more information, visit: https://github.com/orgs/supabase/discussions/37217
2025-08-15T13:21:01Z app[5683970eae6308] sin [info]🚀 Clio Fly.io API Server running on port 3000
2025-08-15T13:21:01Z app[5683970eae6308] sin [info]🌍 Region: sin
2025-08-15T13:21:01Z app[5683970eae6308] sin [info]🔗 Health check: http://localhost:3000/health
2025-08-15T13:21:01Z app[5683970eae6308] sin [info]📡 Ready to receive requests from www.cliovoice.com
2025-08-15T13:21:05Z app[5683970eae6308] sin [info]🌐 [FLY-LLM] Model: meta-llama/llama-4-scout-17b-16e-instruct, Text length: 794 chars
2025-08-15T13:21:06Z app[5683970eae6308] sin [info]❌ [FLY-LLM] Proxy error: DOMException [AbortError]: This operation was aborted
2025-08-15T13:21:06Z app[5683970eae6308] sin [info]    at node:internal/deps/undici/undici:12637:11
2025-08-15T13:21:06Z app[5683970eae6308] sin [info]    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
2025-08-15T13:21:06Z app[5683970eae6308] sin [info]    at async llmProxy (file:///app/src/routes/llm.js:78:26)
2025-08-15T13:21:06Z app[5683970eae6308] sin [info]file:///app/src/routes/llm.js:145
2025-08-15T13:21:06Z app[5683970eae6308] sin [info]      res.setHeader('X-Flex-Timeout-MS', String(FLEX_TIMEOUT_MS));
2025-08-15T13:21:06Z app[5683970eae6308] sin [info]                                                ^
2025-08-15T13:21:06Z app[5683970eae6308] sin [info]ReferenceError: FLEX_TIMEOUT_MS is not defined
2025-08-15T13:21:06Z app[5683970eae6308] sin [info]    at llmProxy (file:///app/src/routes/llm.js:145:49)
2025-08-15T13:21:06Z app[5683970eae6308] sin [info]    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
2025-08-15T13:21:06Z app[5683970eae6308] sin [info]Node.js v18.20.8
2025-08-15T13:21:06Z proxy[5683970eae6308] sin [error][PU02] could not complete HTTP request to instance: connection closed before message completed
2025-08-15T13:21:06Z app[5683970eae6308] sin [info]npm notice
2025-08-15T13:21:06Z app[5683970eae6308] sin [info]npm notice New major version of npm available! 10.8.2 -> 11.5.2
2025-08-15T13:21:06Z app[5683970eae6308] sin [info]npm notice Changelog: https://github.com/npm/cli/releases/tag/v11.5.2
2025-08-15T13:21:06Z app[5683970eae6308] sin [info]npm notice To update run: npm install -g npm@11.5.2
2025-08-15T13:21:06Z app[5683970eae6308] sin [info]npm notice
2025-08-15T13:21:07Z app[5683970eae6308] sin [info] INFO Main child exited normally with code: 1
2025-08-15T13:21:07Z app[5683970eae6308] sin [info] INFO Starting clean up.
2025-08-15T13:21:07Z app[5683970eae6308] sin [info] WARN could not unmount /rootfs: EINVAL: Invalid argument
2025-08-15T13:21:07Z app[5683970eae6308] sin [info][    7.750261] reboot: Restarting system
2025-08-15T13:21:08Z app[5683970eae6308] sin [info]2025-08-15T13:21:08.378096972 [01K2A5BMF9XXQBYHK379ZN3EVM:main] Running Firecracker v1.12.1
2025-08-15T13:21:08Z app[5683970eae6308] sin [info]2025-08-15T13:21:08.378211393 [01K2A5BMF9XXQBYHK379ZN3EVM:main] Listening on API socket ("/fc.sock").
2025-08-15T13:21:09Z app[5683970eae6308] sin [info] INFO Starting init (commit: 6c3309ba)...
2025-08-15T13:21:09Z app[5683970eae6308] sin [info] INFO Preparing to run: `docker-entrypoint.sh npm start` as nodejs
2025-08-15T13:21:09Z app[5683970eae6308] sin [info] INFO [fly api proxy] listening at /.fly/api
2025-08-15T13:21:09Z runner[5683970eae6308] sin [info]Machine started in 830ms
2025-08-15T13:21:09Z app[5683970eae6308] sin [info]2025/08/15 13:21:09 INFO SSH listening listen_address=[fdaa:25:25c4:a7b:4ff:9914:1cd8:2]:22
2025-08-15T13:21:09Z app[5683970eae6308] sin [info]> clio-flyio-api@1.0.0 start
2025-08-15T13:21:09Z app[5683970eae6308] sin [info]> node src/index.js
2025-08-15T13:21:10Z app[5683970eae6308] sin [info]⚠️  Node.js 18 and below are deprecated and will no longer be supported in future versions of @supabase/supabase-js. Please upgrade to Node.js 20 or later. For more information, visit: https://github.com/orgs/supabase/discussions/37217
2025-08-15T13:21:10Z app[5683970eae6308] sin [info]🚀 Clio Fly.io API Server running on port 3000
2025-08-15T13:21:10Z app[5683970eae6308] sin [info]🌍 Region: sin
2025-08-15T13:21:10Z app[5683970eae6308] sin [info]🔗 Health check: http://localhost:3000/health
2025-08-15T13:21:10Z app[5683970eae6308] sin [info]📡 Ready to receive requests from www.cliovoice.com
2025-08-15T13:21:25Z app[5683970eae6308] sin [info]🌐 [FLY-LLM] Model: meta-llama/llama-4-scout-17b-16e-instruct, Text length: 794 chars
2025-08-15T13:21:26Z app[5683970eae6308] sin [info]❌ [FLY-LLM] Proxy error: DOMException [AbortError]: This operation was aborted
2025-08-15T13:21:26Z app[5683970eae6308] sin [info]    at node:internal/deps/undici/undici:12637:11
2025-08-15T13:21:26Z app[5683970eae6308] sin [info]    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
2025-08-15T13:21:26Z app[5683970eae6308] sin [info]    at async llmProxy (file:///app/src/routes/llm.js:78:26)
2025-08-15T13:21:26Z app[5683970eae6308] sin [info]file:///app/src/routes/llm.js:145
2025-08-15T13:21:26Z app[5683970eae6308] sin [info]      res.setHeader('X-Flex-Timeout-MS', String(FLEX_TIMEOUT_MS));
2025-08-15T13:21:26Z app[5683970eae6308] sin [info]                                                ^
2025-08-15T13:21:26Z app[5683970eae6308] sin [info]ReferenceError: FLEX_TIMEOUT_MS is not defined
2025-08-15T13:21:26Z app[5683970eae6308] sin [info]    at llmProxy (file:///app/src/routes/llm.js:145:49)
2025-08-15T13:21:26Z app[5683970eae6308] sin [info]    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
2025-08-15T13:21:26Z app[5683970eae6308] sin [info]Node.js v18.20.8
2025-08-15T13:21:26Z proxy[5683970eae6308] sin [error][PU02] could not complete HTTP request to instance: connection closed before message completed
2025-08-15T13:21:26Z app[5683970eae6308] sin [info]npm notice
2025-08-15T13:21:26Z app[5683970eae6308] sin [info]npm notice New major version of npm available! 10.8.2 -> 11.5.2
2025-08-15T13:21:26Z app[5683970eae6308] sin [info]npm notice Changelog: https://github.com/npm/cli/releases/tag/v11.5.2
2025-08-15T13:21:26Z app[5683970eae6308] sin [info]npm notice To update run: npm install -g npm@11.5.2
2025-08-15T13:21:26Z app[5683970eae6308] sin [info]npm notice
2025-08-15T13:21:27Z app[5683970eae6308] sin [info] INFO Main child exited normally with code: 1
2025-08-15T13:21:27Z app[5683970eae6308] sin [info] INFO Starting clean up.
2025-08-15T13:21:27Z app[5683970eae6308] sin [info] WARN could not unmount /rootfs: EINVAL: Invalid argument
2025-08-15T13:21:27Z app[5683970eae6308] sin [info][   18.738071] reboot: Restarting system
2025-08-15T13:21:27Z app[5683970eae6308] sin [info]2025-08-15T13:21:27.862268982 [01K2A5BMF9XXQBYHK379ZN3EVM:main] Running Firecracker v1.12.1
2025-08-15T13:21:27Z app[5683970eae6308] sin [info]2025-08-15T13:21:27.862388783 [01K2A5BMF9XXQBYHK379ZN3EVM:main] Listening on API socket ("/fc.sock").
2025-08-15T13:21:28Z app[5683970eae6308] sin [info] INFO Starting init (commit: 6c3309ba)...
2025-08-15T13:21:28Z app[5683970eae6308] sin [info] INFO Preparing to run: `docker-entrypoint.sh npm start` as nodejs
2025-08-15T13:21:28Z app[5683970eae6308] sin [info] INFO [fly api proxy] listening at /.fly/api
2025-08-15T13:21:28Z runner[5683970eae6308] sin [info]Machine started in 836ms
2025-08-15T13:21:28Z app[5683970eae6308] sin [info]2025/08/15 13:21:28 INFO SSH listening listen_address=[fdaa:25:25c4:a7b:4ff:9914:1cd8:2]:22
2025-08-15T13:21:29Z app[5683970eae6308] sin [info]> clio-flyio-api@1.0.0 start
2025-08-15T13:21:29Z app[5683970eae6308] sin [info]> node src/index.js
2025-08-15T13:21:29Z app[5683970eae6308] sin [info]⚠️  Node.js 18 and below are deprecated and will no longer be supported in future versions of @supabase/supabase-js. Please upgrade to Node.js 20 or later. For more information, visit: https://github.com/orgs/supabase/discussions/37217
2025-08-15T13:21:29Z app[5683970eae6308] sin [info]🚀 Clio Fly.io API Server running on port 3000
2025-08-15T13:21:29Z app[5683970eae6308] sin [info]🌍 Region: sin
2025-08-15T13:21:29Z app[5683970eae6308] sin [info]🔗 Health check: http://localhost:3000/health
2025-08-15T13:21:29Z app[5683970eae6308] sin [info]📡 Ready to receive requests from www.cliovoice.com
2025-08-15T13:21:52Z app[5683970eae6308] sin [info]🔐 [AUTH] auth_1755264112836 - Session creation request
2025-08-15T13:21:52Z app[5683970eae6308] sin [info]🔍 [AUTH] auth_1755264112836 - Creating session for deviceId: clio_D26..., email: none
2025-08-15T13:21:52Z app[5683970eae6308] sin [info]✅ [AUTH] auth_1755264112836 - Session created, generating JWT...
2025-08-15T13:21:52Z app[5683970eae6308] sin [info]✅ [AUTH] auth_1755264112836 - JWT created successfully in 3ms
2025-08-15T13:21:52Z app[5683970eae6308] sin [info]POST /api/auth/session-inline - 200 (12ms)
2025-08-15T13:21:52Z app[5683970eae6308] sin [info]🔐 [FLY-ASR] asr_1755264112852 - Temporary key request
2025-08-15T13:21:52Z app[5683970eae6308] sin [info]✅ [FLY-ASR] asr_1755264112852 - Authenticated user: unknown
2025-08-15T13:21:52Z app[5683970eae6308] sin [info]🌐 [FLY-ASR] asr_1755264112852 - Calling Soniox API with retry logic...
2025-08-15T13:21:53Z app[5683970eae6308] sin [info]🌐 [FLY-LLM] Model: meta-llama/llama-4-scout-17b-16e-instruct, Text length: 741 chars
2025-08-15T13:21:54Z app[5683970eae6308] sin [info]❌ [FLY-LLM] Proxy error: DOMException [AbortError]: This operation was aborted
2025-08-15T13:21:54Z app[5683970eae6308] sin [info]    at node:internal/deps/undici/undici:12637:11
2025-08-15T13:21:54Z app[5683970eae6308] sin [info]    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
2025-08-15T13:21:54Z app[5683970eae6308] sin [info]    at async llmProxy (file:///app/src/routes/llm.js:78:26)
2025-08-15T13:21:54Z app[5683970eae6308] sin [info]file:///app/src/routes/llm.js:145
2025-08-15T13:21:54Z app[5683970eae6308] sin [info]      res.setHeader('X-Flex-Timeout-MS', String(FLEX_TIMEOUT_MS));
2025-08-15T13:21:54Z app[5683970eae6308] sin [info]                                                ^
2025-08-15T13:21:54Z app[5683970eae6308] sin [info]ReferenceError: FLEX_TIMEOUT_MS is not defined
2025-08-15T13:21:54Z app[5683970eae6308] sin [info]    at llmProxy (file:///app/src/routes/llm.js:145:49)
2025-08-15T13:21:54Z app[5683970eae6308] sin [info]    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
2025-08-15T13:21:54Z app[5683970eae6308] sin [info]Node.js v18.20.8
2025-08-15T13:21:54Z proxy[5683970eae6308] sin [error][PU02] could not complete HTTP request to instance: connection closed before message completed
2025-08-15T13:21:54Z proxy[5683970eae6308] sin [error][PU02] could not complete HTTP request to instance: connection closed before message completed
2025-08-15T13:21:54Z app[5683970eae6308] sin [info]npm notice
2025-08-15T13:21:54Z app[5683970eae6308] sin [info]npm notice New major version of npm available! 10.8.2 -> 11.5.2
2025-08-15T13:21:54Z app[5683970eae6308] sin [info]npm notice Changelog: https://github.com/npm/cli/releases/tag/v11.5.2
2025-08-15T13:21:54Z app[5683970eae6308] sin [info]npm notice To update run: npm install -g npm@11.5.2
2025-08-15T13:21:54Z app[5683970eae6308] sin [info]npm notice
2025-08-15T13:21:55Z proxy[5683970eae6308] sin [error][PR03] could not find a good candidate within 1 attempts at load balancing. last error: [PC01] instance refused connection. is your app listening on 0.0.0.0:3000? make sure it is not only listening on 127.0.0.1 (hint: look at your startup logs, servers often print the address they are listening on)
2025-08-15T13:21:55Z app[286e297be19758] sjc [info]🔐 [FLY-ASR] asr_1755264115525 - Temporary key request
2025-08-15T13:21:55Z app[286e297be19758] sjc [info]✅ [FLY-ASR] asr_1755264115525 - Authenticated user: unknown
2025-08-15T13:21:55Z app[286e297be19758] sjc [info]🌐 [FLY-ASR] asr_1755264115525 - Calling Soniox API with retry logic...
2025-08-15T13:21:55Z app[5683970eae6308] sin [info] INFO Main child exited normally with code: 1
2025-08-15T13:21:55Z app[5683970eae6308] sin [info] INFO Starting clean up.
2025-08-15T13:21:55Z app[5683970eae6308] sin [info] WARN could not unmount /rootfs: EINVAL: Invalid argument
2025-08-15T13:21:55Z app[5683970eae6308] sin [info][   27.736004] reboot: Restarting system
2025-08-15T13:21:55Z app[286e297be19758] sjc [info]🌐 [FLY-ASR-METRICS] Performance Summary:
2025-08-15T13:21:55Z app[286e297be19758] sjc [info]🌐   Total: 274ms | Network: 273ms (100%) | Soniox: 274ms (100%) | Proxy: 0ms (0%)
2025-08-15T13:21:55Z app[286e297be19758] sjc [info]🌐   Bottleneck: network | Recommendation: Network latency high - check edge regions or connection pooling
2025-08-15T13:21:55Z app[286e297be19758] sjc [info]🌐   Connection: 🔄 NEW CONNECTION (handshake ~164ms) | Pattern: cold_start
2025-08-15T13:21:55Z app[286e297be19758] sjc [info]🌐   Region: sjc | Client: unknown | Payload: 0KB→0KB
2025-08-15T13:21:55Z app[286e297be19758] sjc [info]{"timestamp":"2025-08-15T13:21:55.799Z","level":"ASR_NETWORK_METRICS","total_ms":274,"ttfb_ms":273,"soniox_ms":274,"proxy_ms":0,"network_ms":273,"breakdown_percent":{"network_latency":100,"soniox_processing":100,"proxy_overhead":0},"primary_bottleneck":"network","client_country":"unknown","client_ip":"111.3.34.68, 66.241.125.161","server_region":"sjc","request_kb":0.1,"response_kb":0.1,"connection_reused":false,"handshake_cost_estimate":164,"time_since_last_request":857541,"full_diagnostics":{"network":{"soniox_connection":{"ttfb":273,"total_time":274,"download_time":1,"connection_reused":false,"time_since_last_request":857541,"estimated_handshake_cost":164},"client":{"ip":"111.3.34.68, 66.241.125.161","country":"unknown","user_agent":"Clio/1420 CFNetwork/3826.400.120 Darwin/24.3.0","connection_type":"unknown"}},"processing":{"proxy_overhead":{"pre_processing":0,"post_processing":0,"total":0,"breakdown":{"auth":0,"validation":0,"response_building":0}},"soniox_internal":{"total":274,"ttfb":273}},"efficiency":{"time_breakdown_percent":{"network_latency":100,"soniox_processing":100,"proxy_overhead":0},"insights":{"primary_bottleneck":"network","optimization_target":"Network latency high - check edge regions or connection pooling","connection_efficiency":{"likely_reused":false,"handshake_cost_estimate":164,"client_pattern":"cold_start"}}},"infrastructure":{"server_region":"sjc","server_instance":"286e297b","timestamp":"2025-08-15T13:21:55.799Z","request_size":114,"response_size":85},"totals":{"end_to_end":274,"external_api":274,"proxy_work":0,"soniox_processing":274,"network_latency":273},"breakdown":{"network":100,"soniox":100,"proxy":0}}}
2025-08-15T13:21:55Z app[286e297be19758] sjc [info]POST /api/asr/temp-key - 200 (276ms)
2025-08-15T13:21:56Z app[5683970eae6308] sin [info]2025-08-15T13:21:56.770464784 [01K2A5BMF9XXQBYHK379ZN3EVM:main] Running Firecracker v1.12.1
2025-08-15T13:21:56Z app[5683970eae6308] sin [info]2025-08-15T13:21:56.770597745 [01K2A5BMF9XXQBYHK379ZN3EVM:main] Listening on API socket ("/fc.sock").
2025-08-15T13:21:57Z app[5683970eae6308] sin [info] INFO Starting init (commit: 6c3309ba)...
2025-08-15T13:21:57Z app[5683970eae6308] sin [info] INFO Preparing to run: `docker-entrypoint.sh npm start` as nodejs
2025-08-15T13:21:57Z app[5683970eae6308] sin [info] INFO [fly api proxy] listening at /.fly/api
2025-08-15T13:21:57Z runner[5683970eae6308] sin [info]Machine started in 825ms
2025-08-15T13:21:57Z app[286e297be19758] sjc [info]🔐 [FLY-ASR] asr_1755264117555 - Temporary key request
2025-08-15T13:21:57Z app[286e297be19758] sjc [info]✅ [FLY-ASR] asr_1755264117555 - Authenticated user: unknown
2025-08-15T13:21:57Z app[286e297be19758] sjc [info]🌐 [FLY-ASR] asr_1755264117555 - Calling Soniox API with retry logic...
2025-08-15T13:21:57Z app[286e297be19758] sjc [info]🌐 [FLY-ASR-METRICS] Performance Summary:
2025-08-15T13:21:57Z app[286e297be19758] sjc [info]🌐   Total: 85ms | Network: 85ms (100%) | Soniox: 85ms (100%) | Proxy: 0ms (0%)
2025-08-15T13:21:57Z app[286e297be19758] sjc [info]🌐   Bottleneck: network | Recommendation: Network latency high - check edge regions or connection pooling
2025-08-15T13:21:57Z app[286e297be19758] sjc [info]🌐   Connection: ✅ LIKELY REUSED | Pattern: rapid_fire
2025-08-15T13:21:57Z app[286e297be19758] sjc [info]🌐   Region: sjc | Client: unknown | Payload: 0KB→0KB
2025-08-15T13:21:57Z app[286e297be19758] sjc [info]{"timestamp":"2025-08-15T13:21:57.640Z","level":"ASR_NETWORK_METRICS","total_ms":85,"ttfb_ms":85,"soniox_ms":85,"proxy_ms":0,"network_ms":85,"breakdown_percent":{"network_latency":100,"soniox_processing":100,"proxy_overhead":0},"primary_bottleneck":"network","client_country":"unknown","client_ip":"111.3.34.68, 66.241.125.161","server_region":"sjc","request_kb":0.1,"response_kb":0.1,"connection_reused":true,"handshake_cost_estimate":0,"time_since_last_request":2030,"full_diagnostics":{"network":{"soniox_connection":{"ttfb":85,"total_time":85,"download_time":0,"connection_reused":true,"time_since_last_request":2030,"estimated_handshake_cost":0},"client":{"ip":"111.3.34.68, 66.241.125.161","country":"unknown","user_agent":"Clio/1420 CFNetwork/3826.400.120 Darwin/24.3.0","connection_type":"unknown"}},"processing":{"proxy_overhead":{"pre_processing":0,"post_processing":0,"total":0,"breakdown":{"auth":0,"validation":0,"response_building":0}},"soniox_internal":{"total":85,"ttfb":85}},"efficiency":{"time_breakdown_percent":{"network_latency":100,"soniox_processing":100,"proxy_overhead":0},"insights":{"primary_bottleneck":"network","optimization_target":"Network latency high - check edge regions or connection pooling","connection_efficiency":{"likely_reused":true,"handshake_cost_estimate":0,"client_pattern":"rapid_fire"}}},"infrastructure":{"server_region":"sjc","server_instance":"286e297b","timestamp":"2025-08-15T13:21:57.640Z","request_size":114,"response_size":85},"totals":{"end_to_end":85,"external_api":85,"proxy_work":0,"soniox_processing":85,"network_latency":85},"breakdown":{"network":100,"soniox":100,"proxy":0}}}
2025-08-15T13:21:57Z app[286e297be19758] sjc [info]POST /api/asr/temp-key - 200 (86ms)
2025-08-15T13:21:57Z app[5683970eae6308] sin [info]2025/08/15 13:21:57 INFO SSH listening listen_address=[fdaa:25:25c4:a7b:4ff:9914:1cd8:2]:22
2025-08-15T13:21:58Z app[5683970eae6308] sin [info]> clio-flyio-api@1.0.0 start
2025-08-15T13:21:58Z app[5683970eae6308] sin [info]> node src/index.js
2025-08-15T13:21:58Z app[5683970eae6308] sin [info]⚠️  Node.js 18 and below are deprecated and will no longer be supported in future versions of @supabase/supabase-js. Please upgrade to Node.js 20 or later. For more information, visit: https://github.com/orgs/supabase/discussions/37217
2025-08-15T13:21:58Z app[5683970eae6308] sin [info]🚀 Clio Fly.io API Server running on port 3000
2025-08-15T13:21:58Z app[5683970eae6308] sin [info]🌍 Region: sin
2025-08-15T13:21:58Z app[5683970eae6308] sin [info]🔗 Health check: http://localhost:3000/health
2025-08-15T13:21:58Z app[5683970eae6308] sin [info]📡 Ready to receive requests from www.cliovoice.com
2025-08-15T13:22:54Z app[5683970eae6308] sin [info]🌐 [FLY-LLM] Model: meta-llama/llama-4-scout-17b-16e-instruct, Text length: 741 chars
2025-08-15T13:22:55Z app[5683970eae6308] sin [info]❌ [FLY-LLM] Proxy error: DOMException [AbortError]: This operation was aborted
2025-08-15T13:22:55Z app[5683970eae6308] sin [info]    at node:internal/deps/undici/undici:12637:11
2025-08-15T13:22:55Z app[5683970eae6308] sin [info]    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
2025-08-15T13:22:55Z app[5683970eae6308] sin [info]    at async llmProxy (file:///app/src/routes/llm.js:78:26)
2025-08-15T13:22:55Z app[5683970eae6308] sin [info]file:///app/src/routes/llm.js:145
2025-08-15T13:22:55Z app[5683970eae6308] sin [info]      res.setHeader('X-Flex-Timeout-MS', String(FLEX_TIMEOUT_MS));
2025-08-15T13:22:55Z app[5683970eae6308] sin [info]                                                ^
2025-08-15T13:22:55Z app[5683970eae6308] sin [info]ReferenceError: FLEX_TIMEOUT_MS is not defined
2025-08-15T13:22:55Z app[5683970eae6308] sin [info]    at llmProxy (file:///app/src/routes/llm.js:145:49)
2025-08-15T13:22:55Z app[5683970eae6308] sin [info]    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
2025-08-15T13:22:55Z app[5683970eae6308] sin [info]Node.js v18.20.8
2025-08-15T13:22:55Z proxy[5683970eae6308] sin [error][PU02] could not complete HTTP request to instance: connection closed before message completed
2025-08-15T13:22:55Z app[5683970eae6308] sin [info]npm notice
2025-08-15T13:22:55Z app[5683970eae6308] sin [info]npm notice New major version of npm available! 10.8.2 -> 11.5.2
2025-08-15T13:22:55Z app[5683970eae6308] sin [info]npm notice Changelog: https://github.com/npm/cli/releases/tag/v11.5.2
2025-08-15T13:22:55Z app[5683970eae6308] sin [info]npm notice To update run: npm install -g npm@11.5.2
2025-08-15T13:22:55Z app[5683970eae6308] sin [info]npm notice
2025-08-15T13:22:56Z app[5683970eae6308] sin [info] INFO Main child exited normally with code: 1
2025-08-15T13:22:56Z app[5683970eae6308] sin [info] INFO Starting clean up.
2025-08-15T13:22:56Z app[5683970eae6308] sin [info] WARN could not unmount /rootfs: EINVAL: Invalid argument
2025-08-15T13:22:56Z app[5683970eae6308] sin [info][   59.765456] reboot: Restarting system
2025-08-15T13:22:57Z app[5683970eae6308] sin [info]2025-08-15T13:22:57.441014507 [01K2A5BMF9XXQBYHK379ZN3EVM:main] Running Firecracker v1.12.1
2025-08-15T13:22:57Z app[5683970eae6308] sin [info]2025-08-15T13:22:57.441144258 [01K2A5BMF9XXQBYHK379ZN3EVM:main] Listening on API socket ("/fc.sock").
2025-08-15T13:22:58Z app[5683970eae6308] sin [info] INFO Starting init (commit: 6c3309ba)...
2025-08-15T13:22:58Z app[5683970eae6308] sin [info] INFO Preparing to run: `docker-entrypoint.sh npm start` as nodejs
2025-08-15T13:22:58Z app[5683970eae6308] sin [info] INFO [fly api proxy] listening at /.fly/api
2025-08-15T13:22:58Z runner[5683970eae6308] sin [info]Machine started in 835ms
2025-08-15T13:22:58Z app[5683970eae6308] sin [info]2025/08/15 13:22:58 INFO SSH listening listen_address=[fdaa:25:25c4:a7b:4ff:9914:1cd8:2]:22
2025-08-15T13:22:58Z app[5683970eae6308] sin [info]> clio-flyio-api@1.0.0 start
2025-08-15T13:22:58Z app[5683970eae6308] sin [info]> node src/index.js
2025-08-15T13:22:59Z app[5683970eae6308] sin [info]⚠️  Node.js 18 and below are deprecated and will no longer be supported in future versions of @supabase/supabase-js. Please upgrade to Node.js 20 or later. For more information, visit: https://github.com/orgs/supabase/discussions/37217
2025-08-15T13:22:59Z app[5683970eae6308] sin [info]🚀 Clio Fly.io API Server running on port 3000
2025-08-15T13:22:59Z app[5683970eae6308] sin [info]🌍 Region: sin
2025-08-15T13:22:59Z app[5683970eae6308] sin [info]🔗 Health check: http://localhost:3000/health
2025-08-15T13:22:59Z app[5683970eae6308] sin [info]📡 Ready to receive requests from www.cliovoice.com
2025-08-15T13:24:22Z app[5683970eae6308] sin [info]🔐 [AUTH] auth_1755264262559 - Session creation request
2025-08-15T13:24:22Z app[5683970eae6308] sin [info]🔍 [AUTH] auth_1755264262559 - Creating session for deviceId: clio_784..., email: none
2025-08-15T13:24:22Z app[5683970eae6308] sin [info]✅ [AUTH] auth_1755264262559 - Session created, generating JWT...
2025-08-15T13:24:22Z app[5683970eae6308] sin [info]✅ [AUTH] auth_1755264262559 - JWT created successfully in 3ms
2025-08-15T13:24:22Z app[5683970eae6308] sin [info]POST /api/auth/session-inline - 200 (12ms)
2025-08-15T13:24:22Z app[5683970eae6308] sin [info]🌐 [FLY-LLM] Model: meta-llama/llama-4-scout-17b-16e-instruct, Text length: 1201 chars
2025-08-15T13:24:23Z app[5683970eae6308] sin [info]❌ [FLY-LLM] Proxy error: DOMException [AbortError]: This operation was aborted
2025-08-15T13:24:23Z app[5683970eae6308] sin [info]    at node:internal/deps/undici/undici:12637:11
2025-08-15T13:24:23Z app[5683970eae6308] sin [info]    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
2025-08-15T13:24:23Z app[5683970eae6308] sin [info]    at async llmProxy (file:///app/src/routes/llm.js:78:26)
2025-08-15T13:24:23Z app[5683970eae6308] sin [info]file:///app/src/routes/llm.js:145
2025-08-15T13:24:23Z app[5683970eae6308] sin [info]      res.setHeader('X-Flex-Timeout-MS', String(FLEX_TIMEOUT_MS));
2025-08-15T13:24:23Z app[5683970eae6308] sin [info]                                                ^
2025-08-15T13:24:23Z app[5683970eae6308] sin [info]ReferenceError: FLEX_TIMEOUT_MS is not defined
2025-08-15T13:24:23Z app[5683970eae6308] sin [info]    at llmProxy (file:///app/src/routes/llm.js:145:49)
2025-08-15T13:24:23Z app[5683970eae6308] sin [info]    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
2025-08-15T13:24:23Z app[5683970eae6308] sin [info]Node.js v18.20.8
2025-08-15T13:24:23Z proxy[5683970eae6308] sin [error][PU02] could not complete HTTP request to instance: connection closed before message completed
2025-08-15T13:24:23Z app[5683970eae6308] sin [info]npm notice
2025-08-15T13:24:23Z app[5683970eae6308] sin [info]npm notice New major version of npm available! 10.8.2 -> 11.5.2
2025-08-15T13:24:23Z app[5683970eae6308] sin [info]npm notice Changelog: https://github.com/npm/cli/releases/tag/v11.5.2
2025-08-15T13:24:23Z app[5683970eae6308] sin [info]npm notice To update run: npm install -g npm@11.5.2
2025-08-15T13:24:23Z app[5683970eae6308] sin [info]npm notice
2025-08-15T13:24:24Z app[5683970eae6308] sin [info] INFO Main child exited normally with code: 1
2025-08-15T13:24:24Z app[5683970eae6308] sin [info] INFO Starting clean up.
2025-08-15T13:24:24Z app[5683970eae6308] sin [info] WARN could not unmount /rootfs: EINVAL: Invalid argument
2025-08-15T13:24:24Z app[5683970eae6308] sin [info][   86.805708] reboot: Restarting system
2025-08-15T13:24:26Z app[5683970eae6308] sin [info]2025-08-15T13:24:26.745895623 [01K2A5BMF9XXQBYHK379ZN3EVM:main] Running Firecracker v1.12.1
2025-08-15T13:24:26Z app[5683970eae6308] sin [info]2025-08-15T13:24:26.746013655 [01K2A5BMF9XXQBYHK379ZN3EVM:main] Listening on API socket ("/fc.sock").
2025-08-15T13:24:27Z app[5683970eae6308] sin [info] INFO Starting init (commit: 6c3309ba)...
2025-08-15T13:24:27Z app[5683970eae6308] sin [info] INFO Preparing to run: `docker-entrypoint.sh npm start` as nodejs
2025-08-15T13:24:27Z app[5683970eae6308] sin [info] INFO [fly api proxy] listening at /.fly/api
2025-08-15T13:24:27Z runner[5683970eae6308] sin [info]Machine started in 869ms
2025-08-15T13:24:27Z app[5683970eae6308] sin [info]2025/08/15 13:24:27 INFO SSH listening listen_address=[fdaa:25:25c4:a7b:4ff:9914:1cd8:2]:22
2025-08-15T13:24:28Z app[5683970eae6308] sin [info]> clio-flyio-api@1.0.0 start
2025-08-15T13:24:28Z app[5683970eae6308] sin [info]> node src/index.js
2025-08-15T13:24:28Z app[5683970eae6308] sin [info]⚠️  Node.js 18 and below are deprecated and will no longer be supported in future versions of @supabase/supabase-js. Please upgrade to Node.js 20 or later. For more information, visit: https://github.com/orgs/supabase/discussions/37217
2025-08-15T13:24:28Z app[5683970eae6308] sin [info]🚀 Clio Fly.io API Server running on port 3000
2025-08-15T13:24:28Z app[5683970eae6308] sin [info]🌍 Region: sin
2025-08-15T13:24:28Z app[5683970eae6308] sin [info]🔗 Health check: http://localhost:3000/health
2025-08-15T13:24:28Z app[5683970eae6308] sin [info]📡 Ready to receive requests from www.cliovoice.com
2025-08-15T13:24:33Z app[5683970eae6308] sin [info]🌐 [FLY-LLM] Model: qwen/qwen3-32b, Text length: 1775 chars
2025-08-15T13:24:33Z app[5683970eae6308] sin [info]🐛 [DEBUG] Timestamps: response_complete=1755264273821, response_built=1755264273821, diff=0
2025-08-15T13:24:33Z app[5683970eae6308] sin [info]🌐 [FLY-METRICS] Performance Summary:
2025-08-15T13:24:33Z app[5683970eae6308] sin [info]🌐   Total: 365ms | Network: 203ms (58%) | Groq: 145ms (42%) | Proxy: 1ms (0%)
2025-08-15T13:24:33Z app[5683970eae6308] sin [info]🌐   Groq Breakdown: Queue=52ms | Prompt=64ms | Completion=29ms | TTFT=116ms
2025-08-15T13:24:33Z app[5683970eae6308] sin [info]🌐   Bottleneck: network | Recommendation: Network latency high - check edge regions or connection pooling
2025-08-15T13:24:33Z app[5683970eae6308] sin [info]🌐   Connection: 🔄 NEW CONNECTION (handshake ~203ms) | Pattern: cold_start
2025-08-15T13:24:33Z app[5683970eae6308] sin [info]🌐   Region: sin | Client: unknown | Payload: 4KB→1KB
2025-08-15T13:24:33Z app[5683970eae6308] sin [info]{"timestamp":"2025-08-15T13:24:33.826Z","level":"NETWORK_METRICS","total_ms":365,"ttfb_ms":339,"groq_ms":145,"proxy_ms":1,"network_ms":203,"breakdown_percent":{"network_latency":58,"groq_processing":42,"proxy_overhead":0,"download_time":3},"primary_bottleneck":"network","client_country":"unknown","client_ip":"54.169.43.104, 66.241.125.161","server_region":"sin","request_kb":4.2,"response_kb":0.6,"groq_queue_ms":52,"groq_prompt_ms":64,"groq_completion_ms":29,"groq_ttft_ms":116,"connection_reused":false,"handshake_cost_estimate":203,"time_since_last_request":1755264273473,"full_diagnostics":{"network":{"groq_connection":{"ttfb":339,"total_time":348,"download_time":9,"connection_reused":false,"time_since_last_request":1755264273473,"estimated_handshake_cost":203},"client":{"ip":"54.169.43.104, 66.241.125.161","country":"unknown","user_agent":"Clio/1420 CFNetwork/3826.600.41 Darwin/24.6.0","connection_type":"unknown"}},"processing":{"proxy_overhead":{"pre_processing":1,"post_processing":0,"total":1,"breakdown":{"auth":0,"validation":1,"json_parsing":0,"response_building":0}},"groq_internal":{"total":145,"queue":52,"prompt":64,"completion":29,"ttft":116}},"efficiency":{"time_breakdown_percent":{"network_latency":58,"groq_processing":42,"proxy_overhead":0,"download_time":3},"insights":{"primary_bottleneck":"network","optimization_target":"Network latency high - check edge regions or connection pooling","connection_efficiency":{"likely_reused":false,"handshake_cost_estimate":203,"client_pattern":"cold_start"}}},"infrastructure":{"server_region":"sin","server_instance":"5683970e","timestamp":"2025-08-15T13:24:33.826Z","request_size":4317,"response_size":569},"totals":{"end_to_end":365,"external_api":348,"proxy_work":1,"groq_processing":145,"network_latency":203},"groq_details":{"queue_time":52,"prompt_time":64,"completion_time":29,"ttft":116},"breakdown":{"network":58,"groq":42,"proxy":0}}}
2025-08-15T13:24:33Z app[5683970eae6308] sin [info]POST /api/llm/proxy - 200 (368ms)
2025-08-15T13:24:44Z app[5683970eae6308] sin [info]🌐 [FLY-LLM] Model: meta-llama/llama-4-scout-17b-16e-instruct, Text length: 1201 chars
2025-08-15T13:24:45Z app[5683970eae6308] sin [info]❌ [FLY-LLM] Proxy error: DOMException [AbortError]: This operation was aborted
2025-08-15T13:24:45Z app[5683970eae6308] sin [info]    at node:internal/deps/undici/undici:12637:11
2025-08-15T13:24:45Z app[5683970eae6308] sin [info]    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
2025-08-15T13:24:45Z app[5683970eae6308] sin [info]    at async llmProxy (file:///app/src/routes/llm.js:78:26)
2025-08-15T13:24:45Z app[5683970eae6308] sin [info]file:///app/src/routes/llm.js:145
2025-08-15T13:24:45Z app[5683970eae6308] sin [info]      res.setHeader('X-Flex-Timeout-MS', String(FLEX_TIMEOUT_MS));
2025-08-15T13:24:45Z app[5683970eae6308] sin [info]                                                ^
2025-08-15T13:24:45Z app[5683970eae6308] sin [info]ReferenceError: FLEX_TIMEOUT_MS is not defined
2025-08-15T13:24:45Z app[5683970eae6308] sin [info]    at llmProxy (file:///app/src/routes/llm.js:145:49)
2025-08-15T13:24:45Z app[5683970eae6308] sin [info]    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
2025-08-15T13:24:45Z app[5683970eae6308] sin [info]Node.js v18.20.8
2025-08-15T13:24:45Z proxy[5683970eae6308] sin [error][PU02] could not complete HTTP request to instance: connection closed before message completed
2025-08-15T13:24:45Z app[5683970eae6308] sin [info]npm notice
2025-08-15T13:24:45Z app[5683970eae6308] sin [info]npm notice New major version of npm available! 10.8.2 -> 11.5.2
2025-08-15T13:24:45Z app[5683970eae6308] sin [info]npm notice Changelog: https://github.com/npm/cli/releases/tag/v11.5.2
2025-08-15T13:24:45Z app[5683970eae6308] sin [info]npm notice To update run: npm install -g npm@11.5.2
2025-08-15T13:24:45Z app[5683970eae6308] sin [info]npm notice
2025-08-15T13:24:46Z app[5683970eae6308] sin [info] INFO Main child exited normally with code: 1
2025-08-15T13:24:46Z app[5683970eae6308] sin [info] INFO Starting clean up.
2025-08-15T13:24:46Z app[5683970eae6308] sin [info] WARN could not unmount /rootfs: EINVAL: Invalid argument
2025-08-15T13:24:46Z app[5683970eae6308] sin [info][   19.751215] reboot: Restarting system
2025-08-15T13:24:52Z app[5683970eae6308] sin [info]2025-08-15T13:24:52.556524356 [01K2A5BMF9XXQBYHK379ZN3EVM:main] Running Firecracker v1.12.1
2025-08-15T13:24:52Z app[5683970eae6308] sin [info]2025-08-15T13:24:52.556640317 [01K2A5BMF9XXQBYHK379ZN3EVM:main] Listening on API socket ("/fc.sock").
2025-08-15T13:24:53Z app[5683970eae6308] sin [info] INFO Starting init (commit: 6c3309ba)...
2025-08-15T13:24:53Z app[5683970eae6308] sin [info] INFO Preparing to run: `docker-entrypoint.sh npm start` as nodejs
2025-08-15T13:24:53Z app[5683970eae6308] sin [info] INFO [fly api proxy] listening at /.fly/api
2025-08-15T13:24:53Z runner[5683970eae6308] sin [info]Machine started in 839ms
2025-08-15T13:24:53Z app[5683970eae6308] sin [info]2025/08/15 13:24:53 INFO SSH listening listen_address=[fdaa:25:25c4:a7b:4ff:9914:1cd8:2]:22
2025-08-15T13:24:54Z app[5683970eae6308] sin [info]> clio-flyio-api@1.0.0 start
2025-08-15T13:24:54Z app[5683970eae6308] sin [info]> node src/index.js
