const http = require("http");
const fs = require("fs");
const path = require("path");
const { exec } = require("child_process");
const WebSocket = require("ws");

const PORT = 7475;
const WS_PORT = 7476;

// Get file from command line arguments
const filePath = process.argv[2];
let initialContent = "";
let initialFileName = "";
let watchedFilePath = null;

if (filePath) {
  try {
    const absolutePath = path.resolve(filePath);
    if (fs.existsSync(absolutePath)) {
      initialContent = fs.readFileSync(absolutePath, "utf-8");
      initialFileName = path.basename(absolutePath);
      watchedFilePath = absolutePath;
      console.log(
        `✅ Loaded file: ${absolutePath} (${initialContent.length} bytes)`,
      );
    } else {
      console.error(`❌ File not found: ${absolutePath}`);
    }
  } catch (err) {
    console.error(`❌ Error reading file: ${err.message}`);
  }
}

// WebSocket server for hot-reloading
const wss = new WebSocket.Server({ port: WS_PORT });
const clients = new Set();

wss.on("connection", (ws) => {
  clients.add(ws);
  console.log(`🔌 Client connected (${clients.size} total)`);

  ws.on("close", () => {
    clients.delete(ws);
    console.log(`🔌 Client disconnected (${clients.size} remaining)`);
  });
});

function broadcastUpdate(content, filename) {
  const message = JSON.stringify({ type: "update", content, filename });
  clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(message);
    }
  });
  console.log(`📡 Broadcasted update to ${clients.size} client(s)`);
}

// File watcher
let watcher = null;
if (watchedFilePath) {
  fs.watchFile(watchedFilePath, { interval: 300 }, (curr, prev) => {
    if (curr.mtime !== prev.mtime) {
      try {
        const newContent = fs.readFileSync(watchedFilePath, "utf-8");
        initialContent = newContent;
        console.log(`🔄 File changed, reloading (${newContent.length} bytes)`);
        broadcastUpdate(newContent, initialFileName);
      } catch (err) {
        console.error(`❌ Error reading updated file: ${err.message}`);
      }
    }
  });
  console.log(`👀 Watching for changes: ${watchedFilePath}`);
}

const html = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Markdown Live Viewer - High Contrast</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.2.0/github-markdown.min.css">
    <style>
		:root {
    		--bg-color: #0d1117;           /* Dark background */
    		--container-bg: #161b22;       /* Slightly lighter container */
    		--accent-color: #58a6ff;       /* Bright blue for links/buttons */
    		--border-color: #30363d;       /* Visible borders */
    		--text-color: #e6edf3;         /* High contrast white text */
    		--issue-color: #ff7b72;        /* Bright red for issues */
    		--recommendation-color: #56d364; /* Bright green for recommendations */
    		--code-bg: #1f2937;            /* Dark code background */
    		--code-text: #79c0ff;          /* Bright code text */
		}

		.markdown-body strong { 
    		color: #ff7b72;  /* Bright red for bold */
    		font-weight: 700; 
		}

		.markdown-body code { 
    		background-color: var(--code-bg); 
    		color: var(--code-text); 
    		font-weight: 600; 
		}

		/* Regular paragraph text - ensure high contrast */
		.markdown-body p {
    		color: #e6edf3;  /* Bright white, not muted gray */
		}

		/* Links with better visibility */
		.markdown-body a {
    		color: var(--accent-color);
    		text-decoration: underline;
		}


        body {
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
    		background-color: #0d1117;     /* Match dark theme */
    		color: var(--text-color);
        }

        #drop-zone {
            position: fixed;
            top: 0; left: 0; width: 100%; height: 100%;
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            border: 4px dashed var(--accent-color);
            z-index: 1000;
            transition: all 0.3s ease;
      	  	background-color: rgba(88, 166, 255, 0.1);
        }

        #drop-zone.hidden { display: none; }
        #drop-zone.dragover { background-color: rgba(0, 92, 197, 0.15); border-color: #1f883d; }

        .markdown-body {
            box-sizing: border-box;
            min-width: 200px;
            max-width: 1012px;
            margin: 0 auto;
            padding: 45px;
            min-height: 100vh;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            border-left: 1px solid var(--border-color);
            border-right: 1px solid var(--border-color);
    		background-color: var(--container-bg);
    		color: var(--text-color);
        }

        /* High Contrast Enhancements */
        .markdown-body h1, .markdown-body h2 {
  	  	  	padding-bottom: 0.3em; color: #000;
    		border-bottom: 2px solid var(--border-color); 
    		color: #f0f6fc;  /* Brightest white for headings */
  	  	}
        .markdown-body strong { color: #cf222e; } /* Make bold text pop */
        .markdown-body code { background-color: #f0f2f5; color: #005cc5; font-weight: 600; border-radius: 4px; padding: 2px 4px; }
        
        /* Custom highlight for specific sections */
        .issue-text { color: var(--issue-color); font-weight: bold; }
        .recommendation-text { color: var(--recommendation-color); font-weight: bold; }

        #controls { position: fixed; bottom: 20px; right: 20px; display: flex; gap: 10px; z-index: 1001; }
        .btn {
            padding: 10px 20px;
            background: var(--accent-color);
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }
        .btn:hover { background: #004da3; transform: translateY(-1px); }
        #file-info { 
            position: fixed; 
            top: 10px; 
            right: 20px; 
            font-size: 13px; 
            font-weight: 600; 
            color: #57606a; 
            background: rgba(255,255,255,0.8); 
            padding: 4px 8px; 
            border-radius: 4px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .status-indicator {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #1a7f37;
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }

        /* Mermaid styling */
        .mermaid {
            background: white !important;
            display: flex;
            justify-content: center;
            padding: 0;
            margin: 20px 0;
            border-radius: 8px;
            border: 1px solid var(--border-color);
            height: 500px; /* Fixed height for zoomable area */
            overflow: hidden;
            position: relative;
        }
        .mermaid svg {
            width: 100% !important;
            height: 100% !important;
            max-width: none !important;
        }
    </style>
</head>
<body>
    <div id="drop-zone">
        <h1 style="color: var(--accent-color); font-size: 2.5em;">⚡ Markdown Pro Viewer</h1>
        <p style="font-size: 1.2em; color: #57606a;">Drop your .md file here for high-contrast rendering</p>
        <button class="btn" onclick="document.getElementById('file-input').click()">Select File</button>
        <input type="file" id="file-input" style="display:none" accept=".md,.markdown,.txt">
    </div>

    <div id="file-info"></div>
    <div id="content" class="markdown-body" style="display:none"></div>

    <div id="controls">
        <button class="btn" onclick="showDropZone()">Open New File</button>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/svg-pan-zoom@3.6.1/dist/svg-pan-zoom.min.js"></script>
    <script type="module">
        import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
        
        mermaid.initialize({ 
            startOnLoad: false, 
            theme: 'neutral',
            securityLevel: 'loose'
        });

        const dropZone = document.getElementById('drop-zone');
        const contentDiv = document.getElementById('content');
        const fileInfo = document.getElementById('file-info');
        const fileInput = document.getElementById('file-input');

        // WebSocket connection for hot-reloading
        let ws = null;
        let reconnectTimeout = null;

        function connectWebSocket() {
            ws = new WebSocket('ws://localhost:${WS_PORT}');
            
            ws.onopen = () => {
                console.log('🔌 WebSocket connected - hot-reloading enabled');
                updateStatus(true);
            };
            
            ws.onmessage = (event) => {
                const data = JSON.parse(event.data);
                if (data.type === 'update') {
                    console.log('🔄 Received update from server');
                    renderMarkdown(data.content, data.filename);
                }
            };
            
            ws.onclose = () => {
                console.log('🔌 WebSocket disconnected');
                updateStatus(false);
                // Attempt to reconnect after 2 seconds
                reconnectTimeout = setTimeout(connectWebSocket, 2000);
            };
            
            ws.onerror = (error) => {
                console.error('WebSocket error:', error);
            };
        }

        function updateStatus(connected) {
            const indicator = fileInfo.querySelector('.status-indicator');
            if (indicator) {
                indicator.style.background = connected ? '#1a7f37' : '#d1242f';
            }
        }

        // Configure marked to handle mermaid code blocks
        marked.use({
            renderer: {
                code(code) {
                    const text = typeof code === 'object' ? code.text : code;
                    const lang = typeof code === 'object' ? code.lang : arguments[1];
                    
                    if (lang === 'mermaid') {
                        return \`<div class="mermaid">\${text}</div>\`;
                    }
                    return false;
                }
            }
        });

        function showDropZone() {
            dropZone.classList.remove('hidden');
            contentDiv.style.display = 'none';
        }

        function hideDropZone() {
            dropZone.classList.add('hidden');
            contentDiv.style.display = 'block';
        }

        async function renderMarkdown(text, name) {
            if (!text) return;
            
            console.log('Rendering:', name);
            
            let processedText = text.replace(/\\*\\*Issue:\\*\\*/g, '**<span class="issue-text">Issue:</span>**');
            processedText = processedText.replace(/\\*\\*Recommendation:\\*\\*/g, '**<span class="recommendation-text">Recommendation:</span>**');
            
            contentDiv.innerHTML = marked.parse(processedText);
            fileInfo.innerHTML = '<span class="status-indicator"></span>📄 ' + name;
            hideDropZone();
            window.scrollTo(0, 0);

            // Run mermaid rendering
            const mermaidDivs = document.querySelectorAll('.mermaid');
            if (mermaidDivs.length > 0) {
                try {
                    await mermaid.run({
                        nodes: mermaidDivs,
                    });
                    
                    // Initialize zoom/pan on rendered SVGs
                    mermaidDivs.forEach(div => {
                        const svg = div.querySelector('svg');
                        if (svg) {
                            // Enable svg-pan-zoom
                            svgPanZoom(svg, {
                                zoomEnabled: true,
                                controlIconsEnabled: true,
                                fit: true,
                                center: true,
                                minZoom: 0.1,
                                maxZoom: 20
                            });
                        }
                    });
                } catch (err) {
                    console.error('Mermaid error:', err);
                }
            }
            
            // Update status indicator if it exists
            updateStatus(ws && ws.readyState === WebSocket.OPEN);
        }

        function handleFile(file) {
            if (!file) return;
            const reader = new FileReader();
            reader.onload = (e) => {
                renderMarkdown(e.target.result, file.name);
            };
            reader.readAsText(file);
        }

        fetch('/api/content')
            .then(res => res.json())
            .then(data => {
                if (data.content) {
                    renderMarkdown(data.content, data.filename);
                    // Connect WebSocket after initial content is loaded
                    connectWebSocket();
                }
            })
            .catch(err => console.error('Error fetching content:', err));

        window.addEventListener('dragover', (e) => { e.preventDefault(); dropZone.classList.add('dragover'); });
        window.addEventListener('dragleave', (e) => { e.preventDefault(); dropZone.classList.remove('dragover'); });
        window.addEventListener('drop', (e) => { e.preventDefault(); dropZone.classList.remove('dragover'); handleFile(e.dataTransfer.files[0]); });
        fileInput.addEventListener('change', (e) => { handleFile(e.target.files[0]); });

        window.showDropZone = showDropZone;
        
        // Cleanup on page unload
        window.addEventListener('beforeunload', () => {
            if (ws) ws.close();
            if (reconnectTimeout) clearTimeout(reconnectTimeout);
        });
    </script>
</body>
</html>
`;

const server = http.createServer((req, res) => {
  if (req.url === "/api/content") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(
      JSON.stringify({ content: initialContent, filename: initialFileName }),
    );
    return;
  }
  res.writeHead(200, { "Content-Type": "text/html" });
  res.end(html);
});

server.listen(PORT, () => {
  const url = `http://localhost:${PORT}`;
  console.log(`\n🚀 Markdown Viewer Server running at ${url}`);
  console.log(`🔌 WebSocket server running on port ${WS_PORT}`);
  if (filePath) {
    console.log(`📂 Attempting to open: ${filePath}`);
    exec(`open "${url}"`, (error) => {
      if (error) console.error(`❌ Failed to open browser: ${error.message}`);
    });
  }
});

// Graceful shutdown
process.on("SIGINT", () => {
  console.log("\n🛑 Shutting down...");
  if (watcher) fs.unwatchFile(watchedFilePath);
  wss.close();
  server.close();
  process.exit(0);
});
