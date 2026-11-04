const { spawn } = require("child_process");
const path = require("path");

// Resolve directories
const rootDir = path.resolve(__dirname, "..");
const backendDir = path.join(rootDir, "Smart_Farm_Backend");
const frontendDir = path.join(rootDir, "farm");

// Parse arguments (e.g. node run.js --target=chrome or --target=windows)
const args = process.argv.slice(2);
let targetDevice = "chrome"; // Default to Chrome for fast local web preview

for (const arg of args) {
  if (arg.startsWith("--target=")) {
    targetDevice = arg.split("=")[1];
  } else if (arg === "--windows") {
    targetDevice = "windows";
  } else if (arg === "--chrome") {
    targetDevice = "chrome";
  } else if (arg === "--edge") {
    targetDevice = "edge";
  } else if (arg === "--android") {
    targetDevice = "android";
  }
}

console.log("\x1b[36m====================================================\x1b[0m");
console.log("\x1b[36m🌱 SMART FARM UNIFIED LAUNCHER\x1b[0m");
console.log("\x1b[36m====================================================\x1b[0m");
console.log(`📂 Backend Dir : ${backendDir}`);
console.log(`📂 Frontend Dir: ${frontendDir}`);
console.log(`🎯 Frontend Target Device: ${targetDevice}`);
console.log("\x1b[33m⚡ Press 'r' in this terminal for Flutter hot-reload\x1b[0m");
console.log("\x1b[33m⚡ Press 'R' for hot-restart, 'q' to quit\x1b[0m");
console.log("\x1b[36m----------------------------------------------------\x1b[0m\n");

// Messages from Flutter's web debug service that are pure noise (not real errors)
const FLUTTER_NOISE_PATTERNS = [
  "DebugService: Error serving requests",
  "Unsupported operation: Cannot send Null",
  "SocketException: Write failed",
  "WebSocketChannelException",
];

// Helper to prefix output streams, with optional noise filtering
function pipeWithPrefix(stream, prefixColor, prefixText, filter = false) {
  let buffer = "";
  stream.on("data", (chunk) => {
    buffer += chunk.toString();
    const lines = buffer.split("\n");
    buffer = lines.pop(); // keep remainder
    for (const line of lines) {
      if (line.trim().length === 0) continue;
      // If filter is enabled, skip known noisy/false-error lines
      if (filter && FLUTTER_NOISE_PATTERNS.some((p) => line.includes(p))) continue;
      process.stdout.write(`${prefixColor}[${prefixText}]\x1b[0m ${line}\n`);
    }
  });
}

// 1. Launch Backend (npm start or npm run dev)
const isWindows = process.platform === "win32";
const npmCmd = isWindows ? "npm.cmd" : "npm";
const flutterCmd = isWindows ? "flutter.bat" : "flutter";

console.log("\x1b[34m[LAUNCHER]\x1b[0m Starting Backend API on http://localhost:5000 ...");
const backend = spawn(npmCmd, ["run", "dev"], {
  cwd: backendDir,
  shell: true,
  env: { ...process.env, PORT: process.env.PORT || "5000" },
});

pipeWithPrefix(backend.stdout, "\x1b[34m", "BACKEND");
pipeWithPrefix(backend.stderr, "\x1b[31m", "BACKEND-ERR");

backend.on("error", (err) => {
  console.error("\x1b[31m[BACKEND-FAIL]\x1b[0m", err);
});

// 2. Launch Frontend (flutter run -d <target>)
console.log(`\x1b[32m[LAUNCHER]\x1b[0m Starting Flutter Frontend (target: ${targetDevice}) ...`);
const flutterArgs = ["run"];
if (targetDevice) {
  flutterArgs.push("-d", targetDevice);
}

const frontend = spawn(flutterCmd, flutterArgs, {
  cwd: frontendDir,
  shell: true,
  stdio: ["pipe", "pipe", "pipe"],
});

pipeWithPrefix(frontend.stdout, "\x1b[32m", "FRONTEND");
pipeWithPrefix(frontend.stderr, "\x1b[33m", "FRONTEND-WARN", true); // filter=true suppresses Flutter debug service noise

frontend.on("error", (err) => {
  console.error("\x1b[31m[FRONTEND-FAIL]\x1b[0m", err);
});

// Forward user keyboard input to Flutter for interactive hot-reload (r / R / q)
if (process.stdin.isTTY) {
  process.stdin.setRawMode(true);
  process.stdin.resume();
  process.stdin.on("data", (data) => {
    // Check for Ctrl+C (0x03)
    if (data[0] === 3) {
      cleanExit();
      return;
    }
    // Forward to Flutter stdin
    if (frontend.stdin && !frontend.stdin.destroyed) {
      frontend.stdin.write(data);
    }
  });
}

function cleanExit() {
  console.log("\n\x1b[33m[LAUNCHER] Shutting down services...\x1b[0m");
  try {
    if (isWindows) {
      // Force kill process trees on Windows
      if (backend.pid) spawn("taskkill", ["/pid", backend.pid, "/f", "/t"]);
      if (frontend.pid) spawn("taskkill", ["/pid", frontend.pid, "/f", "/t"]);
    } else {
      backend.kill("SIGTERM");
      frontend.kill("SIGTERM");
    }
  } catch (_) {}
  setTimeout(() => process.exit(0), 1000);
}

process.on("SIGINT", cleanExit);
process.on("SIGTERM", cleanExit);
