/**
 * WARNING: This demo is a barebones implementation designed for development and evaluation
 * purposes only. It is definitely NOT production ready and does not aim to be so. Exposing the
 * demo to the public as is would introduce security risks for the host.
 **/

import express from "express";
import expressWs from "express-ws";
import pty from "node-pty";
import { HOST, PORT } from "../../shared/src/constants";

export function startServer() {
  const app = express();
  const appWs = expressWs(app).app;

  const terminals: Record<number, pty.IPty> = {};
  const unsentOutput: Record<number, string> = {};
  const temporaryDisposable: Record<number, pty.IDisposable> = {};

  app.use(express.json());

  app.post("/terminals", (req, res) => {
    const env: Record<string, string> = {};
    env["COLORTERM"] = "truecolor";

    const cwd = process.env.PWD?.replace("presentation/backend", "demo");

    if (
      typeof req.query.cols !== "string" ||
      typeof req.query.rows !== "string"
    ) {
      console.error({ req });
      throw new Error("Unexpected query args");
    }
    const cols = parseInt(req.query.cols);
    const rows = parseInt(req.query.rows);

    const term = pty.spawn(
      "bash",
      [
        "-c",
        // Launch a reproducible and isolated shell environment in which
        // all tools required for the demo are available
        "/nix/var/nix/profiles/default/bin/nix develop " +
          "--ignore-environment --keep TERM --keep COLORTERM " +
          ".#nix-demo-env",
      ],
      {
        name: "xterm-256color",
        cols: cols ?? 80,
        rows: rows ?? 24,
        cwd,
        env,
        encoding: "utf8",
      }
    );

    console.log("Created terminal with PID: " + term.pid);

    terminals[term.pid] = term;
    unsentOutput[term.pid] = "";
    temporaryDisposable[term.pid] = term.onData(function (data) {
      unsentOutput[term.pid] += data;
    });
    res.send(term.pid.toString());
    res.end();
  });

  app.post("/terminals/:pid/size", (req, res) => {
    if (
      typeof req.query.cols !== "string" ||
      typeof req.query.rows !== "string"
    ) {
      console.error({ req });
      throw new Error("Unexpected query args");
    }
    const pid = parseInt(req.params.pid);
    const cols = parseInt(req.query.cols);
    const rows = parseInt(req.query.rows);
    const term = terminals[pid];

    term.resize(cols, rows);
    console.log(`Resized terminal ${pid} to ${cols} cols and ${rows} rows.`);
    res.end();
  });

  app.post("/terminals/:pid/exec", (req, res) => {
    const term = terminals[parseInt(req.params.pid)];
    const command = `${req.body.command}\n`;
    term.write(command);
    res.end();
  });

  appWs.ws("/terminals/:pid", function (ws, req) {
    const term = terminals[parseInt(req.params.pid)];
    console.log("Connected to terminal " + term.pid);
    temporaryDisposable[term.pid].dispose();
    delete temporaryDisposable[term.pid];
    ws.send(unsentOutput[term.pid]);
    delete unsentOutput[term.pid];

    // unbuffered delivery after user input
    let userInput = false;

    function buffer(socket: typeof ws, timeout: number, maxSize: number) {
      const chunks: Buffer[] = [];
      let length = 0;
      let sender: NodeJS.Timeout | null = null;
      return (data: Buffer) => {
        chunks.push(data);
        length += data.length;
        if (length > maxSize || userInput) {
          userInput = false;
          socket.send(Buffer.concat(chunks));
          chunks.length = 0;
          length = 0;
          if (sender) {
            clearTimeout(sender);
            sender = null;
          }
        } else if (!sender) {
          sender = setTimeout(() => {
            socket.send(Buffer.concat(chunks));
            chunks.length = 0;
            length = 0;
            sender = null;
          }, timeout);
        }
      };
    }
    const send = buffer(ws, 3, 262144);

    // WARNING: This is a naive implementation that will not throttle the flow of data. This means
    // it could flood the communication channel and make the terminal unresponsive. Learn more about
    // the problem and how to implement flow control at https://xtermjs.org/docs/guides/flowcontrol/
    term.onData(function (data) {
      try {
        send(Buffer.from(data));
      } catch (ex) {
        // The WebSocket is not open, ignore
      }
    });
    ws.on("message", function (msg: string) {
      term.write(msg);
      userInput = true;
    });
    ws.on("close", function () {
      term.kill();
      console.log("Closed terminal " + term.pid);
      // Clean things up
      delete terminals[term.pid];
    });
  });

  console.log(`Server listening on http://${HOST}:${PORT}`);
  app.listen(PORT, HOST, 0);
}

export default startServer;
